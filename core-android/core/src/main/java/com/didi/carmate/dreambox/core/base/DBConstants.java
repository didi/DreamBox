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
    static final String T_ROOT_NODE_NAME = "dbl";    // 模板根节点名称
    static final String T_MAP_NODE_NAME = "map";     // 模板混淆压缩映射表节点名称
    static final String T_IDS_NODE_NAME = "ids";     // 模板混淆压缩映射表节点名称
    static final String DATA_EXT_PREFIX = "ext";     // 每个视图外部数据源模板前缀
    static final String DATA_GLOBAL_PREFIX = "pool"; // 每个接入方的全局变量池模板前缀

    // -------monitor type define-------
    // 记录跟踪
    static final String TRACE_NODE_UNKNOWN = "tech_trace_node_unknown"; // 未知节点
    static final String TRACE_ATTR_UNKNOWN = "tech_trace_attr_unknown"; // 未知节点属性
    static final String TRACE_PARSER_TEMPLATE = "tech_trace_parser_template"; // 节点计数上报
    static final String TRACE_PARSER_DATA_FAIL = "tech_trace_parser_data_fail"; // 数据解析失败计数上报
    public static final String TRACE_ACTION_ALIAS_NOT_FOUND = "tech_trace_action_alias_not_found"; // 触发动作
}
