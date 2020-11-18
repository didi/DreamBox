import hashlib
import re

from lxml import etree
import json
from base64 import b64encode, b64decode

import xml2tree
from common import RawInput, MetaInfo, CompileResult
from debug_bridge import DebugBridge
import logging
import constant

# 需要在XML格式验证前，以字符串格式对一些特殊的字符进行替换，这样最终的xml验证能通过，然后转成的json也没问题
MAGIC_URL = {
    '<': '&lt;',
    '>': '&gt;',
    '&': '&amp;',
    '\'': '&apos;',
    '\"': '&quot;'
}


def replace_url_magic(src_str_):
    p = re.compile(r'[src|srcMock|url]=\"(https?:\/\/[^\"]*)\"')
    found = p.findall(src_str_)
    target_str = src_str_
    for url in found:
        new_url = url
        for source, target in MAGIC_URL.items():
            new_url = new_url.replace(source, target)
        if new_url != url:
            target_str = target_str.replace(url, new_url)
    return target_str


class CompileTask:
    result: CompileResult
    raw_input: RawInput

    def __init__(self, raw: RawInput, exist_bridge: DebugBridge = None) -> None:
        super().__init__()
        self.raw_input = raw
        self.bridge = exist_bridge

    def compile(self):
        logging.debug('编译中...')

        if self.raw_input.src_64 is not None:
            "传入的是base64的xml内容字符串"
            raw_xml_string = str(b64decode(self.raw_input.src_64), encoding='utf-8')
        else:
            "传入的是xml文件"
            with open(self.raw_input.src_file, mode='r', encoding='utf-8') as fx:
                raw_xml_string = fx.read()

        if raw_xml_string is None:
            raise Exception('无效的编译输入')
        self.result = self._compileString(raw_xml_string)

        if self.raw_input.debug:
            if self.bridge is not None:
                self.bridge.update(self.result)
            else:
                b = DebugBridge(self.raw_input)
                b.run(self.result)
        if self.raw_input.release:
            print(self.result.compiled_str)

    def _compileString(self, xml_string) -> CompileResult:
        xml_string_ = xml_string
        try:
            # 对其中的http URL中可能存在的特殊字符做替换
            xml_string_ = replace_url_magic(xml_string_)

            etree.XML(xml_string_)
            logging.debug('通过XML有效性检查')
        except etree.XMLSyntaxError as err:
            raise Exception('不是有效的XML，请检查输入文件\n', err)
        json_objects = xml2tree.convert(xml_string_, self.raw_input)
        converted_json = json.dumps(json_objects, indent=1)
        json_bytes_ = bytes(converted_json, encoding='utf-8')
        md5 = hashlib.md5(json_bytes_).hexdigest()
        base64_string_ = b64encode(json_bytes_).decode('utf-8')

        cli_ver_str = "CLI ver: %s" % constant.CLI_VER
        runtime_ver_str = "min support RUNTIME ver: %s" % constant.TARGET_RUNTIME_VER

        # 20位保留字
        keep_internal = '0' * 20
        logging.debug("\tMD5: %s " % md5)
        logging.debug("\t%s" % cli_ver_str)
        logging.debug('\t%s' % runtime_ver_str)
        logging.debug("\tKeep space len: %s" % len(keep_internal))
        logging.debug("\tJson source len: %s" % len(json_bytes_.decode('utf-8')))
        logging.debug("\tBase64 data len: %s" % len(base64_string_))

        meta_info = MetaInfo(md5, cli_ver_str, runtime_ver_str)
        ret = CompileResult()
        ver_str = []
        for num in constant.TARGET_RUNTIME_VER.split('.'):
            ver_str.append('%02d' % int(num))
        ret.compiled_str = md5 + ''.join(ver_str) + keep_internal + base64_string_
        ret.raw_json = converted_json
        ret.raw_xml = xml_string_
        ret.meta_info = meta_info
        return ret
