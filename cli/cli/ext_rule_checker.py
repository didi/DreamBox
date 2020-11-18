from xml2tree import Node, RuleChecker, V2_NEW_TAGS, ViewNode, V3_NEW_TAGS, PackNode, CallbackNode
import constant
import logging


class DBRC(RuleChecker):
    """DreamBox Rule Checker在这里可以书写对于DSL的检查逻辑"""

    def __init__(self) -> None:
        super().__init__()
        self.root = None
        self.skip_version_check = False

    def on_tree_generated(self, root: Node):
        self.root = root
        stack = [self.root]
        while len(stack) > 0:
            n = stack.pop()
            self._on_iterator_node(n)
            if len(n.children) > 0:
                for c in n.children:
                    stack.append(c)

    def _on_iterator_node(self, n: Node):
        if self.skip_version_check is False:
            self._confirm_version(n)
        # TODO 增加对节点结构的检查
        # self._check_meta_only_have_attrs(n)
        # self._check_root_cant_have_view(n)
        # self._check_render_have_only_views(n)
        # self._check_root_have_alias(n)
        # self._check_only_callback_have_actions(n)
        # self._check_only_callback_parent_all_view_and_action(n)
        self._check_list_and_flow_wh(n)
        self._check_pack_dsl(n)

    def _check_pack_dsl(self, n: Node):
        if isinstance(n, PackNode):
            for c in n.children:
                if isinstance(c, CallbackNode):
                    raise Exception(f'pack节点不能有callbck节点，其只能包裹view子视图 ---> {c.tag}')
            if 'width' in n.attrs or 'height' in n.attrs:
                raise Exception('pack节点不能设置宽高属性')

    def _confirm_version(self, n: Node):
        pass
        # logging.debug('confirm target sdk version')
        # if n.tag in V2_NEW_TAGS:
        #     if constant.FORCE_TARGET == constant.RUNTIME_VER_1:
        #         raise Exception(f'已强制适配v1版本DSL，但实际的DSL文件中出现了v2才能支持的标签: {n.tag}')
        #     constant.TARGET_RUNTIME_VER = constant.RUNTIME_VER_2
        #     logging.info(f'min support sdk version auto upgrade to {constant.TARGET_RUNTIME_VER}')
        #     self.skip_version_check = True
        # if n.tag in V3_NEW_TAGS:
        #     constant.TARGET_RUNTIME_VER = constant.RUNTIME_VER_3

    def _check_list_and_flow_wh(self, n: Node):
        if type(n) is not ViewNode:
            return
        if n.parent.tag == 'meta':
            return
        w = 'wrap'
        h = 'wrap'
        try:
            w = n.attrs['width']
            h = n.attrs['height']
        except KeyError:
            pass
        if n.tag == 'list':
            if w == 'wrap' or h == 'wrap':
                raise Exception('list控件的宽和高属性均不可自适应')
        if n.tag == 'flow':
            if w == 'wrap' and h == 'wrap':
                raise Exception('flow控件的宽、高不能都是自适应')
