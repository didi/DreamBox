from lxml import etree

import constant
from common import RawInput
import re
import logging
from version_util import compareVersion

PROGUARD_KEYS = 'abcdefghigklmnopqrstuvwxyz' + 'abcdefghigklmnopqrstuvwxyz'.upper()
INTERNAL_KEEP_PREFIX = '_'

SPECIAL_TAGS = [
    'dbl',
    'render',
    'actionAlias',
    'meta'
]

VIEW_TAGS = [
    'view',
    'text',
    'button',
    'image',
    'progress',
    'loading',
    'list',
    'flow',
    'header',
    'footer',
    'vh',
    'cell',
    'pack',
    'layout'
]

ACTION_TAGS = [
    'log',
    'net',
    'trace',
    'nav',
    'storage',
    'changeMeta',
    'dialog',
    'toast',
    'invoke',
    'closePage',
    'sendEvent'
]

IDREF_ATTRS = [
    'id',
    'leftToLeft',
    'leftToRight',
    'rightToRight',
    'rightToLeft',
    'topToTop',
    'topToBottom',
    'bottomToTop',
    'bottomToBottom'
]

V2_NEW_TAGS = [
    'list', 'flow', 'progress'
]

V3_NEW_TAGS = [
    'cell', 'pack'
]


class Node:
    def __init__(self, tag, parent=None) -> None:
        self.tag = tag
        self.parent = parent
        self.attrs = {}
        self.children = []

    def myType(self) -> str:
        pass

    def __str__(self):
        return 'Node:{type} -{tag}-, attr-count:{count}, children:{children}'.format(type=self.myType(), tag=self.tag,
                                                                                     count=len(self.attrs),
                                                                                     children=self.children)


class DummyNode(Node):
    """代表一些特殊的节点，没有明确的类型"""

    def myType(self) -> str:
        return 'dummy'


class ViewNode(Node):
    def myType(self) -> str:
        return 'view'


class LayoutNode(ViewNode):
    """layout抽象容器节点"""

    def myType(self) -> str:
        return 'layout'


class PackNode(ViewNode):
    """DSL中pack节点的支持，这个节点比较特殊，里边的东西会自动收到children下，只支持view"""

    def myType(self) -> str:
        return 'view-pack'


class ActionNode(Node):
    def myType(self) -> str:
        return 'action'


class CallbackNode(Node):
    def myType(self) -> str:
        return 'callback'


class AttrNode(Node):
    def myType(self) -> str:
        return 'attr'


class RuleChecker:
    """外部可以实现此结构用来做对于node tree的检测"""

    def on_tree_generated(self, root: Node):
        pass


def _belong_to(target, parent: Node):
    while parent:
        if type(target) is str:
            if parent.tag == target:
                return True
        elif type(target) is list:
            if parent.tag in target:
                return True
        parent = parent.parent
    return False


class _Converter:
    """接受外部传入的xml数据，以及周边的配置数据，输出是object，可以直接被json化"""

    def __init__(self, xml_str: str, cfg: RawInput, checker: RuleChecker = None) -> None:
        super().__init__()
        # 原始XML string
        self.raw_xml = xml_str
        # 用户输入配置
        self.raw_cfg = cfg
        # 哪些节点的tag可以被视为是view
        self.views = VIEW_TAGS
        self._expand_by_ext_cfg(self.views, 'ext', 'views')
        # 哪些属性可以被视作是对ID的引用
        self.idref_attrs = IDREF_ATTRS
        self._expand_by_ext_cfg(self.idref_attrs, 'ext', 'idref_attrs')
        self.actions = ACTION_TAGS
        self._expand_by_ext_cfg(self.actions, 'ext', 'actions')
        # 自动转化后的成为int类型的ID
        self.int_ids = {}
        # dsl的树状结构根节点
        self.tree_root = None
        # 声明了哪些ID
        self.declared_ids = None
        # 引用了哪些ID
        self.ref_ids = None
        # 总共有多少可以混淆的数据，包括tag和attr
        self.proguard_tokens = None
        # 生成的混淆key集合
        self.proguard_keys = None
        # 可能存在的外部规则检测器
        self.rule_checker = checker

    def _expand_by_ext_cfg(self, target, *cfg_source):
        if self.raw_cfg.ext_cfg is None:
            return
        if type(target) is not list:
            raise Exception('所扩展的属性本身必须是list，请检查代码')
        parent_level = self.raw_cfg.ext_cfg[cfg_source[0]]
        if parent_level:
            child_level = None
            try:
                child_level = parent_level[cfg_source[1]]
            except KeyError:
                pass
            if child_level:
                values = child_level.split(',')
                if values:
                    for v in values:
                        striped_tag = v.strip()
                        if striped_tag not in target:
                            target.append(striped_tag)

    def _wrap_keys(self, key):
        if self.proguard_keys:
            return self.proguard_keys[key]
        else:
            return key

    def convert(self):
        # 首先，确认下使用者是否强制了适配v1版本DSL
        self._xml()
        self._make_id_as_int()
        self._try_gen_proguard_map()
        return self._transform()

    def _make_id_as_int(self):
        if len(self.declared_ids) > 65535:
            raise Exception('过多ID使用，超过65535，请确认必要性并修正')
        for index in range(len(self.declared_ids)):
            # 根据统计到的ID自动将其转换为int，0~65535
            # parent一定一直是0
            id_ = self.declared_ids[index]
            self.int_ids[id_] = str(index)

    def _transform(self):
        # 生成json树（dict）
        root_obj = None
        if compareVersion(constant.TARGET_RUNTIME_VER, constant.RUNTIME_VER_3) <= 0:
            root_obj = self._gen_node_v3(self.tree_root)
        if compareVersion(constant.TARGET_RUNTIME_VER, constant.RUNTIME_VER_4) >= 0:
            root_obj = self._gen_node_v4(self.tree_root)
        proguard_map = None
        obj = {'dbl': root_obj}
        if self.raw_cfg.proguard:
            proguard_map = self._gen_proguard_json_map()
        if proguard_map is not None:
            obj.update(proguard_map)
        if self.int_ids:
            obj.update({'ids': self.int_ids})
        return obj

    def _gen_proguard_json_map(self):
        if self.proguard_keys is None:
            return None
        reversed_map = {}
        for k, v in self.proguard_keys.items():
            reversed_map[v] = k
        return {'map': reversed_map}

    def _gen_node_v4(self, n: Node):
        # 暂时不加入混淆功能
        json_dict = {}
        for k, v in n.attrs.items():
            if isinstance(n, ViewNode) and k in self.idref_attrs:
                json_dict[k] = self.int_ids[v]
            else:
                json_dict[k] = v
        if isinstance(n, ViewNode) or type(n) is CallbackNode:
            # 可能layout的type已经在上边写入过了
            if '_type' not in json_dict.keys():
                json_dict['_type'] = n.tag

        for child in n.children:
            child_type = type(child)
            if child_type is CallbackNode:
                if 'callbacks' not in json_dict.keys():
                    json_dict['callbacks'] = []
                json_dict['callbacks'].append(self._gen_node_v4(child))
            elif isinstance(child, ViewNode):
                if isinstance(n, ViewNode):
                    if 'children' not in json_dict.keys():
                        json_dict['children'] = []
                    json_dict['children'].append(self._gen_node_v4(child))
                if n.tag == 'dbl':
                    json_dict[child.tag] = self._gen_node_v4(child)
            elif child_type is ActionNode:
                if 'actions' not in json_dict.keys():
                    json_dict['actions'] = []
                json_dict['actions'].append({child.tag: self._gen_node_v4(child)})
            else:
                if child.tag in json_dict.keys():
                    # 产生碰撞，即此attr在parent中已经加过，但当时是object，碰撞时要自动转为array
                    exist = json_dict[child.tag]
                    if type(exist) is list:
                        json_dict[child.tag].append(self._gen_node_v4(child))
                    else:
                        del json_dict[child.tag]
                        json_dict[child.tag] = [exist, self._gen_node_v4(child)]
                else:
                    json_dict[child.tag] = self._gen_node_v4(child)
        return json_dict

    def _gen_node_v3(self, n: Node):
        class AutoProguardDict(dict):

            def __init__(self, proguards) -> None:
                super().__init__()
                self.proguards = proguards

            def __getitem__(self, k):
                if k in self.proguards:
                    return super().__getitem__(self.proguards[k])
                else:
                    return super().__getitem__(k)

            def __setitem__(self, k, v) -> None:
                if k in self.proguards:
                    super().__setitem__(self.proguards[k], v)
                else:
                    super().__setitem__(k, v)

            def keys(self):
                maybe_proguard_keys = super().keys()
                origin_keys = []
                for mpk in maybe_proguard_keys:
                    if mpk.startswith(INTERNAL_KEEP_PREFIX):
                        hit = False
                        for k in self.proguards:
                            if self.proguards[k] == mpk:
                                origin_keys.append(k)
                                hit = True
                        if not hit:
                            raise Exception(f'UNLIKELY, 出现了错误的混淆key值，没能在混淆map中找到原值 ({mpk})')
                    else:
                        origin_keys.append(mpk)
                return origin_keys

        if not _belong_to('meta', n) and self.proguard_keys:
            json_dict = AutoProguardDict(self.proguard_keys)
        else:
            json_dict = {}
        if n.tag == 'render':
            # render下只能是view节点，那么把他们作为数组存储，比较特殊的是不用children做key
            json_dict = []
        else:
            # 除了render节点外，其他的节点都可以拥有属性
            for k, v in n.attrs.items():
                if isinstance(n, ViewNode) and k in self.idref_attrs:
                    json_dict[k] = self.int_ids[v]
                else:
                    json_dict[k] = v
        if isinstance(n, ViewNode) or type(n) is CallbackNode:
            # 节点的tag放在内部的type字段下
            json_dict['type'] = n.tag

        for child in n.children:
            if n.tag == 'render':
                json_dict.append(self._gen_node_v3(child))
                continue
            child_type = type(child)
            if child_type is CallbackNode:
                if 'callbacks' not in json_dict.keys():
                    json_dict['callbacks'] = []
                json_dict['callbacks'].append(self._gen_node_v3(child))
            elif isinstance(child, ViewNode):
                if isinstance(n, ViewNode):
                    # parent是一个view容器了
                    if 'children' not in json_dict.keys():
                        json_dict['children'] = []
                    json_dict['children'].append(self._gen_node_v3(child))
            elif child_type is ActionNode:
                if 'actions' not in json_dict.keys():
                    json_dict['actions'] = []
                json_dict['actions'].append({child.tag: self._gen_node_v3(child)})
            else:
                if child.tag in json_dict.keys():
                    # 产生碰撞，即此attr在parent中已经加过，但当时是object，碰撞时要自动转为array
                    exist = json_dict[child.tag]
                    if type(exist) is list:
                        json_dict[child.tag].append(self._gen_node_v3(child))
                    else:
                        del json_dict[child.tag]
                        json_dict[child.tag] = [exist, self._gen_node_v3(child)]
                else:
                    json_dict[child.tag] = self._gen_node_v3(child)
        return json_dict

    def _proguard_tree(self, tree):
        if type(tree) is not dict:
            raise Exception('编译错误，产出类型非tree')
        if self.proguard_keys is None:
            return tree
        for key, value in tree.copy().items():
            after_key, after_value = key, value
            if key in self.proguard_keys.keys():
                after_key = self.proguard_keys[key]
            if type(value) is dict:
                after_value = self._proguard_tree(value)
            if type(value) is list:
                after_value = []
                for child_value in value.copy():
                    if type(child_value) is dict:
                        after_value.append(self._proguard_tree(child_value))
            if after_key != key:
                tree[after_key] = after_value
                del tree[key]
        return tree

    def _xml(self):
        # 构造XML解析器
        parser = etree.XMLParser(ns_clean=True,
                                 remove_comments=True,
                                 no_network=True,
                                 load_dtd=False,
                                 huge_tree=True)
        xml_root = etree.fromstring(self.raw_xml, parser=parser)
        # 关于etree库解析出的xml的基本说明
        # node.tag 节点名称
        # node.text 节点内容 <xxx>123</xxx> 123是内容
        # node.attrib 节点属性
        # 我们最终在意的就是Node类中所定义的数据
        # 1. 首先，构造一个虚拟根节点
        root = DummyNode('root')

        # 当做栈使用，用来按顺序保存解析出来的节点，后续还能够按照顺序转化为json
        # 理解上雷同N叉数利用栈存储以保障顺序
        tag_pointer = [root]
        # 用来存储元数据的数组
        meta_keys = []
        # 存储src、srcMock属性的数据属性数组集合
        src_values = []
        # 存储所有扫描出来的属性名称，作为后续混淆的输入
        attribute_keys = ['type', 'callbacks', 'actions', 'children']
        # 存储所有扫描出来的声明的ID
        declare_ids = ['parent', ]
        # 存储所有扫描出来的被引用的ID
        reference_ids = ['parent', ]
        # 存储所有的节点tag
        element_tags = []

        # 扫描整个XML，收集必要数据
        for node_type, raw_node in etree.iterwalk(xml_root, events=('start', 'end')):
            # xml中可以有-，但是json中不可以，所以默认都换成下划线_（为了适配iOS的json解析）
            # 节点名称，如render、list等，<[节点名称]>
            element_tag = raw_node.tag.replace('-', '_')
            if node_type == 'start':
                if element_tag not in element_tags:
                    element_tags.append(element_tag)
                attrs = {}
                tmp_attr_keys = []
                for attribute_key in raw_node.attrib.keys():
                    attribute_value = raw_node.attrib[attribute_key]
                    if 'noNamespaceSchemaLocation' in attribute_key:
                        # 忽略XSD
                        continue
                    if element_tag == 'meta':
                        if '-' in attribute_key:
                            raise Exception('meta节点的key不可以包含破折号，请替换为下划线')
                        meta_keys.append(attribute_key)
                    else:
                        if attribute_key not in tmp_attr_keys:
                            tmp_attr_keys.append(attribute_key)
                    if attribute_key == 'srcMock' and self.raw_cfg.checkRule:
                        # 严格模式（release模式）将自动移除srcMock字段
                        continue
                    if attribute_key == 'src' or attribute_key == 'srcMock':
                        src_values.append(attribute_value)
                    if attribute_key == 'id' and element_tag in self.views:
                        if attribute_value == 'parent' or attribute_value == '0':
                            raise Exception('不可以定义内容为parent或0的id值，错误行数: ' + str(raw_node.sourceline))
                        if attribute_value not in declare_ids:
                            declare_ids.append(attribute_value)
                    if attribute_key in self.idref_attrs:
                        # 这个属性后的值的意图是引用其他的ID
                        if attribute_value == '0':
                            raise Exception('请使用parent作为id值，0为内部使用协议，不确定未来可用性，错误行数: ' + str(raw_node.sourceline))
                        if attribute_value not in reference_ids:
                            reference_ids.append(attribute_value)
                    if attribute_key == 'width' or attribute_key == 'height':
                        if attribute_value == 'wrap':
                            # 宽高的默认值直接忽略掉
                            continue
                        if str(attribute_value).isdigit():
                            attribute_value += 'dp'
                    attrs[attribute_key] = attribute_value
                current = tag_pointer[-1]
                if not _belong_to('meta', current):
                    # meta节点下的属性不应该被考虑混淆
                    for tk in tmp_attr_keys:
                        if tk not in attribute_keys:
                            attribute_keys.append(tk)
                # 以下构造有顺序，需要格外注意
                if _belong_to('meta', current):
                    # meta下的节点只能是attr
                    n = AttrNode(element_tag)
                elif element_tag == 'pack':
                    if compareVersion(constant.TARGET_RUNTIME_VER, constant.RUNTIME_VER_4) >= 0:
                        raise Exception(f'<pack>节点在{constant.TARGET_RUNTIME_VER}格式下的DSL中不再支持')
                    # pack是一个特殊的view容器节点，不能拥有callback，只可以有children
                    n = PackNode(element_tag)
                elif element_tag == 'layout':
                    n = LayoutNode(element_tag)
                elif element_tag in self.views:
                    n = ViewNode(element_tag)
                elif element_tag in self.actions:
                    n = ActionNode(element_tag)
                elif element_tag in SPECIAL_TAGS:
                    if element_tag == 'render' and compareVersion(constant.TARGET_RUNTIME_VER,
                                                                  constant.RUNTIME_VER_4) >= 0:
                        raise Exception(f'<render>节点在{constant.TARGET_RUNTIME_VER}版本DSL中不再支持')
                    n = DummyNode(element_tag)
                elif str(element_tag).startswith('on'):
                    n = CallbackNode(element_tag)
                elif _belong_to(ACTION_TAGS, current):
                    n = AttrNode(element_tag)
                else:
                    raise Exception(f'未知节点 {element_tag} @line:{raw_node.sourceline}')
                n.attrs = attrs
                n.parent = current
                current.children.append(n)
                tag_pointer.append(n)
            if node_type == 'end':
                tag_pointer.pop()

        logging.debug('通过DSL有效性检查')

        # 是否进行严格DSL规则检查
        if self.raw_cfg.checkRule:
            logging.debug('检测数据有效性...')
            for idref in reference_ids:
                if idref not in declare_ids:
                    raise Exception('XML中出现了未知id，请修正: ' + idref)
            for idref in declare_ids:
                if idref not in reference_ids:
                    raise Exception('XML中声明了多余的id，请修正: ' + idref)

            # 检查src里边的书写是否正确
            for src in src_values:
                # 检查，不支持{name:asd}这样的形式
                match = re.match(r'^{([a-zA-z0-9]*:+.*)}$', src)
                if match:
                    raise Exception('并不支持{xx:xx}这样的数据，请检查：' + src)
                # 检查，${xx.xx}这样的数据引用是否合法，若meta中没有又不是pool或ext则报错
                match = re.match(r'^\${([a-zA-Z_]*)[.]?.*}$', src)
                if match:
                    want_key = match.groups()[0]
                    if want_key not in meta_keys and want_key not in ['pool', 'ext']:
                        raise Exception('src/srcMock所引用的变量在meta中不存在: {}'.format(want_key))
            logging.debug('数据有效性检查通过')

        self.tree_root = root.children[0]
        self.declared_ids = declare_ids
        self.ref_ids = reference_ids
        self.proguard_tokens = []
        for k in attribute_keys:
            if k not in self.proguard_tokens:
                self.proguard_tokens.append(k)
        for k in element_tags:
            if k not in self.proguard_tokens and k != 'dbl':
                self.proguard_tokens.append(k)

        if self.rule_checker:
            self.rule_checker.on_tree_generated(self.tree_root)

    def _try_gen_proguard_map(self):
        # 如果没要求混淆，则退出
        if not self.raw_cfg.proguard:
            return
        # 目前至多支持两位字符串混淆码
        i, j = 0, -1
        self.proguard_keys = {}
        proguard_key_all_used = False
        for key in self.proguard_tokens:
            if proguard_key_all_used:
                break
            while i < len(PROGUARD_KEYS) and j < len(PROGUARD_KEYS):
                one = PROGUARD_KEYS[i]
                two = PROGUARD_KEYS[j]
                # only i
                if i < len(PROGUARD_KEYS) - 1 and j == -1:
                    if one not in self.proguard_keys.values():
                        self.proguard_keys[key] = INTERNAL_KEEP_PREFIX + one
                        i += 1
                        break
                    else:
                        i += 1
                    continue
                elif i == len(PROGUARD_KEYS) - 1 and j == -1:
                    i, j = 0, 0
                    continue
                else:
                    combine = ''.join([one, two])
                    if combine not in self.proguard_keys.values():
                        self.proguard_keys[key] = INTERNAL_KEEP_PREFIX + combine
                        break
                    if i < len(PROGUARD_KEYS) - 1:
                        i += 1
                        continue
                    if j < len(PROGUARD_KEYS) - 1:
                        j += 1
                        continue
                    # 到达这里就是已经都打满了
                    proguard_key_all_used = True
                    if self.raw_cfg.proguard:
                        logging.warning('可用混淆key已用尽')
                    break


def convert(xml: str, cfg: RawInput):
    from ext_rule_checker import DBRC
    return _Converter(xml, cfg, DBRC()).convert()
