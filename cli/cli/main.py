import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from common import RawInput
import constant
import compiler
import logging
from reverse_compile import reverse


def cli():
    from argparse import ArgumentParser
    parser = ArgumentParser(prog='dmb-cli',
                            description="DreamBox的CLI（Command-line interface），目标是对DSL进行编译")
    parser.add_argument('source', nargs='+', help='可接受单个原始文件（XML）作为输入，或DSL字符串两种类型输入参数')
    parser.add_argument('--release', action='store_true', default=False, help='release模式，强校验，直接产出编译产物')
    parser.add_argument('--nocheck', action='store_true', default=False, help='是否强制关闭校验检查')
    parser.add_argument('--noproguard', action='store_true', default=False, help='是否强制关闭压缩混淆')
    parser.add_argument('--extcfg', help='接收开发者自定义的view节点相关配置')
    parser.add_argument('--onlystr', action='store_true', default=False, help='DEBUG模式下生效，开启后只输出编译码字符串')
    parser.add_argument('--reverse', action='store_true', default=False, help='反解编译出来的模板文件')
    parser.add_argument('-v', '--version', action='version',
                        version='DreamBox CLI Version: %s , for RUNTIME: %s' % (
                            constant.CLI_VER, constant.TARGET_RUNTIME_VER))

    args = parser.parse_args()
    if args.release or args.onlystr:
        init_logging()
    else:
        init_logging(logging.DEBUG)
    logging.debug(f'print all arguments:  {vars(args)}')

    if args.source is None or len(args.source) > 1:
        raise Exception('只能接受一个原始输入对象')

    cell = args.source[0]
    src_file = cell
    if args.extcfg:
        extcfg = args.extcfg
        if type(extcfg) is not str:
            raise Exception('此参数需要是文件路径，字符串形式')
        if not os.path.exists(extcfg) or not os.path.isfile(extcfg):
            raise Exception('{}不是文件或不存在'.format(extcfg))
        if not str(args.extcfg).endswith('.yml') and not str(args.extcfg).endswith('.yaml'):
            raise Exception('扩展配置文件必须以yml或yaml结尾，具体配置说明详见文档')
    raw_input = RawInput(args, src_file=src_file)
    if raw_input.reverse:
        reverse(raw_input.src_file)
        return
    if not raw_input.release:
        raw_input.printAttrs()
    c = compiler.CompileTask(raw_input)
    c.compile()


def init_logging(level=None):
    if level is None:
        level = logging.INFO
    logging.basicConfig(format='%(asctime)s [%(levelname)s] %(message)s', level=level)
    logging.debug('logger init done.')


if __name__ == '__main__':
    cli()
    # raw = RawInput.mock_for_debug()
    # raw.src_file = '../demo.xml'
    # c = compiler.CompileTask(raw)
    # c.compile()
