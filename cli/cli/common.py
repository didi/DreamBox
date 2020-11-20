import types
import yaml
import logging


class MetaInfo:
    """DSL编译相关的原始数据"""

    def __init__(self, md5, cli_ver, runtime_ver) -> None:
        super().__init__()
        self.json_md5 = md5
        self.cli_ver = cli_ver
        self.runtime_ver = runtime_ver


class CompileResult:
    """编译后的数据"""
    compiled_str: str
    raw_json: str
    raw_xml: str
    meta_info: MetaInfo


class RawInput:
    """
    用户的纯粹输入，会被加工过
    """
    # 默认态debug
    """
    默认为debug状态，关联动作：
    1. 打开httpserver
    2. 提供ws，以供调试模式使用，自动更新DSL到终端
    """
    debug = True

    """
    只输出编译后的字符串
    """
    only_compile_str = False
    """
    是否是Release状态，需要用户手动打开，若打开：
    1. 默认检查DSL有效性
    2. 默认进行混淆压缩
    """
    release = False

    """
    开启检查，检查DSL的合法性
    """
    checkRule = False

    """
    开启混淆，节省DSL编译后的大小
    """
    proguard = False

    src_file = None

    src_64 = None

    ext_cfg = None

    """
    反解编译后的文件，方便调试问题
    """
    reverse = False

    def printAttrs(self):
        keys = self.__class__.__dict__.keys()
        try:
            for k in keys:
                attr_value = getattr(self, k)
                if type(attr_value) is types.MethodType:
                    continue
                if attr_value is not None and not str(k).startswith('__'):
                    logging.debug(f'\t {k} : {attr_value}')
        except AssertionError:
            pass

    @staticmethod
    def mock_for_debug():
        raw = RawInput()
        raw.debug = True
        raw.checkRule = False
        raw.proguard = False
        raw.release = False
        with open('../ext.yaml', 'r', encoding='utf-8') as cfg_file:
            raw.ext_cfg = yaml.load(cfg_file, Loader=yaml.FullLoader)
        return raw

    def __init__(self, args=None, src_file=None, src_64=None) -> None:
        super().__init__()
        if args is None:
            return
        if src_file is None and src_64 is None:
            raise Exception('无有效数据')
        self.src_file = src_file
        self.src_64 = src_64
        if args.release:
            self.debug = False
            self.release = True
            self.checkRule = True
            self.proguard = True
        if args.nocheck:
            self.checkRule = False
        if args.noproguard:
            self.proguard = False
        if self.debug and args.onlystr:
            self.only_compile_str = True
        if args.extcfg:
            with open(args.extcfg, 'r', encoding='utf-8') as cfg_file:
                self.ext_cfg = yaml.load(cfg_file)
        if args.reverse:
            self.reverse = True
