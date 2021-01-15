package com.didi.carmate.dreambox.core.base;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.DBEngine;
import com.didi.carmate.dreambox.core.utils.DBScreenUtils;


/**
 * author: chenjing
 * date: 2020/5/9
 */
public class DBConstants {
    // -------UI组件尺寸填充类型-------
    public static final String FILL_TYPE_WRAP = "wrap";
    public static final String FILL_TYPE_FILL = "fill";
    // -------样式-------
    public static final String STYLE_TXT_NORMAL = "normal";
    public static final String STYLE_TXT_BOLD = "bold";
    public static final String STYLE_TXT_ITALIC = "italic";
    public static final String STYLE_TXT_STRIKE = "strike";
    public static final String STYLE_TXT_UNDERLINE = "underline";

    public static final String STYLE_VIEW_SHAPE_RECT = "rect";
    public static final String STYLE_VIEW_SHAPE_CIRCLE = "circle";
    public static final String STYLE_ORIENTATION_H = "horizontal";
    public static final String STYLE_ORIENTATION_V = "vertical";
    public static final String STYLE_PATCH_TYPE_STRETCH = "stretch";
    public static final String STYLE_PATCH_TYPE_REPEAT = "repeat";
    public static final String STYLE_GRAVITY_LEFT = "left";
    public static final String STYLE_GRAVITY_RIGHT = "right";
    public static final String STYLE_GRAVITY_TOP = "top";
    public static final String STYLE_GRAVITY_BOTTOM = "bottom";
    public static final String STYLE_GRAVITY_CENTER = "center";
    public static final String STYLE_GRAVITY_CENTER_VERTICAL = "center_vertical";
    public static final String STYLE_GRAVITY_CENTER_HORIZONTAL = "center_horizontal";
    public static final String STYLE_CHAIN_SPREAD = "spread";
    public static final String STYLE_CHAIN_SPREAD_INSIDE = "spread_inside";
    public static final String STYLE_CHAIN_PACKED = "packed";

    // LIST组件Orientation
    public static final String LIST_ORIENTATION_V = "vertical";
    public static final String LIST_ORIENTATION_H = "horizontal";

    // -------DreamBox支持的尺寸单位-------
    public static final String UNIT_TYPE_PX = "px";
    public static final String UNIT_TYPE_DP = "dp";

    // -------UI组件默认ID-------
    public static final int DEFAULT_ID_ROOT = 0;
    public static final int DEFAULT_ID_VIEW = -1;
    // -------UI组件尺寸相关默认值-------
    public static final int DEFAULT_SIZE_WIDTH = ViewGroup.LayoutParams.WRAP_CONTENT;  // 宽
    public static final int DEFAULT_SIZE_HEIGHT = ViewGroup.LayoutParams.WRAP_CONTENT; // 高
    public static final int DEFAULT_SIZE_EDGE = 0; // 边距
    public static final int DEFAULT_SIZE_TEXT = DBScreenUtils.dip2px(DBEngine.getInstance().getApplication(), 13); // 文字大小

    // -------日志级别定义-------
    public static final String LOG_LEVEL_E = "e";
    public static final String LOG_LEVEL_W = "w";
    public static final String LOG_LEVEL_I = "i";
    public static final String LOG_LEVEL_D = "d";
    public static final String LOG_LEVEL_V = "v";

    // -------关键字-------
    public static final String T_ROOT_NODE_NAME = "dbl";    // 模板根节点名称
    public static final String T_MAP_NODE_NAME = "map";     // 模板混淆压缩映射表节点名称
    public static final String T_IDS_NODE_NAME = "ids";     // 模板混淆压缩映射表节点名称
    public static final String DATA_EXT_PREFIX = "ext";     // 每个视图外部数据源模板前缀
    public static final String DATA_GLOBAL_PREFIX = "pool"; // 每个接入方的全局变量池模板前缀

    // -------monitor type define-------
    // 记录跟踪
    public static final String TRACE_NODE_UNKNOWN = "tech_trace_node_unknown"; // 未知节点
    public static final String TRACE_ATTR_UNKNOWN = "tech_trace_attr_unknown"; // 未知节点属性
    public static final String TRACE_PARSER_TEMPLATE = "tech_trace_parser_template"; // 节点计数上报
    public static final String TRACE_PARSER_DATA_FAIL = "tech_trace_parser_data_fail"; // 数据解析失败计数上报
    public static final String TRACE_ACTION_ALIAS_NOT_FOUND = "tech_trace_action_alias_not_found"; // 触发动作

    // -------layout 相关常量定义-------
    // 节点类型
    public static final String UI_ROOT = "layout";
    public static final String UI_TYPE = "_type";
    public static final String UI_LAYOUT = "layout";
    public static final String UI_LAYOUT_TYPE = "type";
    public static final String UI_PAYLOAD = "payload";
    public static final String PAYLOAD_LIST_HEADER = "header";
    public static final String PAYLOAD_LIST_FOOTER = "footer";
    public static final String PAYLOAD_LIST_VH = "vh";
    public static final String PAYLOAD_CELL = "cell";
    // 布局容器类型
    public static final String LAYOUT_TYPE_YOGA = "yoga";
    public static final String LAYOUT_TYPE_FRAME = "frame";
    public static final String LAYOUT_TYPE_LINEAR = "linear";

    // -------FlexBox 相关常量定义-------
    // container:flex-direction
    public static final String FLEX_DIRECTION = "flex-direction";
    public static final String FLEX_DIRECTION_R = "row";
    public static final String FLEX_DIRECTION_C = "column";
    public static final String FLEX_DIRECTION_R_REVERSE = "row-reverse";
    public static final String FLEX_DIRECTION_C_REVERSE = "column-reverse";
    // container:flex-wrap
    public static final String FLEX_WRAP = "flex-wrap";
    public static final String FLEX_WRAP_W = "wrap";
    public static final String FLEX_WRAP_NO_W = "nowrap";
    public static final String FLEX_WRAP_W_REVERSE = "wrap-reverse";
    // container:justify-content
    public static final String JUSTIFY_CONTENT = "justify-content";
    public static final String JUSTIFY_CONTENT_START = "flex-start";
    public static final String JUSTIFY_CONTENT_END = "flex-end";
    public static final String JUSTIFY_CONTENT_CENTER = "center";
    public static final String JUSTIFY_CONTENT_S_BETWEEN = "space-between";
    public static final String JUSTIFY_CONTENT_S_AROUND = "space-around";
    public static final String JUSTIFY_CONTENT_S_EVENLY = "space-evenly";
    // container:align-items
    public static final String ALIGN_ITEMS = "align-items";
    public static final String ALIGN_ITEMS_START = "flex-start";
    public static final String ALIGN_ITEMS_END = "flex-end";
    public static final String ALIGN_ITEMS_CENTER = "center";
    public static final String ALIGN_ITEMS_STRETCH = "stretch";
    public static final String ALIGN_ITEMS_BASELINE = "baseline";
    // container:align-content
    public static final String ALIGN_CONTENT = "align-content";
    public static final String ALIGN_CONTENT_START = "flex-start";
    public static final String ALIGN_CONTENT_END = "flex-end";
    public static final String ALIGN_CONTENT_CENTER = "center";
    public static final String ALIGN_CONTENT_STRETCH = "stretch";
    public static final String ALIGN_CONTENT_S_BETWEEN = "space-between";
    public static final String ALIGN_CONTENT_S_AROUND = "space-around";
    // item:align-self
    public static final String ALIGN_SELF_START = "flex-start";
    public static final String ALIGN_SELF_END = "flex-end";
    public static final String ALIGN_SELF_CENTER = "center";
    public static final String ALIGN_SELF_STRETCH = "stretch";
    public static final String ALIGN_SELF_BASELINE = "baseline";
}
