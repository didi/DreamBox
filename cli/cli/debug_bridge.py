import os
import time
import base64
import datetime
import types
import websockets
import threading
from queue import Queue
import http.server
from jinja2 import Template
from base64 import b64encode
import asyncio
import qrcode
import qrcode.image
import json
import netifaces
import logging
import subprocess

try:
    import importlib.resources as pkg_resources
except ImportError:
    import importlib_resources as pkg_resources

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileSystemEvent

from common import RawInput, CompileResult


def get_v4_ip():
    try:
        iface = netifaces.ifaddresses('eth0')
    except ValueError:
        iface = netifaces.ifaddresses('en0')
    if iface is None:
        raise Exception('获取IP错误')
    return iface[netifaces.AF_INET][0]['addr']


def get_ip():
    return get_v4_ip()


def _get_dir_name_on_path(path: str) -> str:
    """通过路径获取文件夹名"""
    prefix = path.split('/')
    if len(prefix) == 1:
        return '.'
    else:
        return '/'.join(prefix[:-1])


def _get_file_name_on_path(path: str) -> str:
    """通过路径获取文件名"""
    return path.split('/')[-1]


class _DslFileChangeListener(FileSystemEventHandler):

    def __init__(self, dsl_file_name, callback_function) -> None:
        super().__init__()
        self.file_name = dsl_file_name
        self.callback = callback_function
        assert type(callback_function) is types.MethodType

    def on_modified(self, event: FileSystemEvent):
        if not event.is_directory:
            # 是file
            if _get_file_name_on_path(event.src_path) == self.file_name:
                # 修改的就是传入的dsl文件，那么callback
                self.callback()


class _WsResponse:
    TYPE_COMPILED = 'compiled'
    TYPE_MSG = 'msg'
    TYPE_EXT_CMD = 'ext'

    code: int
    data: str

    def __init__(self, code, data, rtype: str) -> None:
        super().__init__()
        self.code = code
        self.data = data
        self.rtype = rtype

    def to_json(self):
        return json.dumps({
            'code': self.code,
            'type': self.rtype,
            'data': self.data
        })


class _DebugServer(threading.Thread):
    _first_time = True
    _http_server = None
    _ws_server = None

    def __init__(self, q: Queue) -> None:
        super().__init__()
        self.q = q
        self.wss_qr = None
        self.wss_addr = None

    def run(self):
        while True:
            logging.debug('Wait for next msg...')
            new_result = self.q.get()
            logging.debug(f'Got msg! ->>>>>>> {new_result}')
            if type(new_result) is CompileResult:
                if self._first_time:
                    self._first_time = False
                    self._real_run(new_result)
                else:
                    self._http_server.shutdown()
                    self._http_server.thread.join()
                    self._publish_local_http(new_result, self.wss_qr, self.wss_addr, True)
                    self._update_wss(new_result)
            if new_result == 'quit':
                # 退出，关闭端口服务，避免异常退出导致的端口占用
                if self._http_server:
                    self._http_server.shutdown()
                    self._http_server.thread.join()
                    logging.debug('http server 已关闭')
                if self._ws_server:
                    self._ws_server.shutdown()
                    logging.debug('websocket server 已关闭')
                break

    def _update_wss(self, new_result):
        self._ws_server.broadcast_new_data(new_result)

    def _real_run(self, result):
        self._publish_wss(result)
        self._publish_local_http(result, self.wss_qr, self.wss_addr)

    def _publish_wss(self, result):
        """发布一个wss，用于广播编译数据，一个新的client连接后将会收到当前最新的编译数据
        一个编译数据更新后，所有的client也能及时获取到最新的编译数据"""
        port = 8891
        tmp_png_file = 'tmp_qr.png'
        ws_address = f'ws://{get_ip()}:{port}'

        qrcode.make(ws_address).save(tmp_png_file)

        class WsServer:
            thread = None
            clients = {}
            server = None
            latest_result = None

            async def _broadcast_new_data(self):
                for client in self.clients.values():
                    await self._send_compiled_string(client)

            def broadcast_new_data(self, new_result):
                self.latest_result = new_result
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                asyncio.get_event_loop().run_until_complete(self._broadcast_new_data())

            def run(self) -> None:
                async def handle_client(websocket, path):
                    try:
                        client_id = websocket.remote_address
                        if client_id not in self.clients.keys():
                            self.clients[client_id] = websocket
                        # 1.st 告诉最新的数据
                        logging.debug(f'new client connected! -->>> {client_id}')
                        await self._send_compiled_string(websocket)
                        # 2.nd 听客户端想要什么
                        while True:
                            logging.debug(f'listen for client -->>> {client_id}')
                            msg = await websocket.recv()
                            logging.debug(f"< {msg}")
                            if msg == 'ask':
                                # 接受ask命令，然后会告诉新数据
                                logging.debug('client ask the latest data')
                                await self._send_compiled_string(websocket)
                            if str(msg).startswith('ext:'):
                                logging.debug('client want set new ext to the mobile')
                                await self._do_ext_command(str(msg)[4:])
                            else:
                                logging.warning('un-supported command come in, check it')
                                resp = _WsResponse(-1, 'not support command', _WsResponse.TYPE_MSG)
                                await websocket.send(resp.to_json())
                    except websockets.ConnectionClosedError:
                        del self.clients[client_id]
                        logging.debug(f'connection lose <<< {client_id}')
                    except websockets.ConnectionClosedOK:
                        del self.clients[client_id]
                        logging.debug(f'connection closed <<< {client_id}')

                self.latest_result = result
                new_loop = asyncio.new_event_loop()
                asyncio.set_event_loop(new_loop)

                logging.getLogger('asyncio').setLevel(logging.ERROR)
                logging.getLogger('asyncio.coroutines').setLevel(logging.ERROR)
                logging.getLogger('websockets.server').setLevel(logging.ERROR)
                logging.getLogger('websockets.protocol').setLevel(logging.ERROR)

                self.server = websockets.serve(handle_client, get_ip(), port)
                logging.debug(f'publish local ws service on -->>> {ws_address}')
                asyncio.get_event_loop().run_until_complete(self.server)
                asyncio.get_event_loop().run_forever()

            def shutdown(self):
                self.server.ws_server.close()

            async def _send_compiled_string(self, client):
                logging.debug('tell client latest compiled string ...')
                resp = _WsResponse(0, self.latest_result.compiled_str, _WsResponse.TYPE_COMPILED)
                await client.send(f"{resp.to_json()}")
                logging.debug('tell client latest compiled string --->>> DONE')

            async def _do_ext_command(self, ext: str):
                logging.debug('send new ext data to client ...')
                resp = _WsResponse(0, ext, _WsResponse.TYPE_EXT_CMD)
                clts = self.clients.values()
                if len(clts) > 0:
                    for c in clts:
                        await c.send(f'{resp.to_json()}')
                logging.debug('send new ext data to client --->>> DONE')

        self._ws_server = WsServer()
        self._ws_server.thread = threading.Thread(None, self._ws_server.run)
        self._ws_server.thread.start()

        with open(tmp_png_file, 'rb') as image_file:
            encoded_string = str(base64.b64encode(image_file.read()), encoding='utf-8')
        os.remove(tmp_png_file)
        self.wss_qr = encoded_string
        self.wss_addr = ws_address

    def _publish_local_http(self, result: CompileResult, qr_64: str, wss_addr: str, update=False):
        """发布一个本地http server用来发布提供编译信息的html"""

        now = datetime.datetime.now()
        now_string = now.strftime('%Y-%m-%d %H:%M:%S.%f')

        class _HttpHandler(http.server.BaseHTTPRequestHandler):
            def do_GET(self):
                self.send_response(200)
                self.send_header('Content-Type', 'text/html')
                self.end_headers()
                # {{ 变量 }}
                # {% 语句 %}
                template_string = pkg_resources.read_text('res', 'debug_info.html.jinja2')
                template = Template(template_string)

                self.wfile.write(bytes(template.render(cstr=result.compiled_str,
                                                       cjson=b64encode(bytes(result.raw_json, encoding='utf-8')).decode(
                                                           'utf-8'),
                                                       now_time=now_string,
                                                       wss=wss_addr,
                                                       img_64=qr_64,
                                                       md5=result.meta_info.json_md5,
                                                       cli_ver=result.meta_info.cli_ver,
                                                       runtime_ver=result.meta_info.runtime_ver), encoding='utf-8'))

        class _HttpServer(http.server.HTTPServer):
            thread = None

            def __init__(self):
                server_address = ('', 8000)
                super().__init__(server_address, _HttpHandler)

            def run(self):
                try:
                    url = f'http://{get_ip()}:{str(self.server_port)}'
                    logging.debug(f'本地调试信息已发布： {url}')
                    if update is False:
                        t = threading.Thread(target=self.delay_open_url, args=(url,))
                        t.daemon = True
                        t.start()
                    self.serve_forever()
                finally:
                    logging.debug('本地调试服务停止')
                    self.server_close()

            @staticmethod
            def delay_open_url(url):
                time.sleep(2)
                logging.debug('try open web page')
                subprocess.Popen(['open', url])

        self._http_server = _HttpServer()
        self._http_server.thread = threading.Thread(None, self._http_server.run)
        self._http_server.thread.start()


class DebugBridge:
    raw_input: RawInput
    dog = None
    dbserver = None

    def __init__(self, raw: RawInput) -> None:
        self.raw_input = raw
        self.queue = Queue(2)

    def update(self, result: CompileResult):
        self.queue.put(result)

    def _on_dsl_change(self):
        logging.debug('changed')
        from compiler import CompileTask
        c = CompileTask(self.raw_input, self)
        try:
            c.compile()
        except Exception as e:
            logging.error(f'ERROR >>> 编译错误，请检查\n{e}')

    def _monitor_file(self):
        event_handler = _DslFileChangeListener(_get_file_name_on_path(self.raw_input.src_file), self._on_dsl_change)
        self.dog = Observer()
        self.dog.schedule(event_handler, _get_dir_name_on_path(self.raw_input.src_file), recursive=False)
        self.dog.start()

    def _open_bridge(self):
        self._monitor_file()
        self.dbserver = _DebugServer(self.queue)
        self.dbserver.daemon = True
        self.dbserver.start()

    def run(self, result: CompileResult):
        self.queue.put(result)
        self._open_bridge()

        logging.debug('输入q回车停止调试')
        while True:
            try:
                user_input = input()
                if str(user_input).lower() == 'q':
                    self.dog.stop()
                    self.queue.put('quit')
                    time.sleep(1)
                    exit(2)
            except InterruptedError or KeyboardInterrupt:
                exit(3)
