package com.didi.carmate.dreambox.core.constraint.base;

import androidx.annotation.NonNull;

import com.didi.carmate.dreambox.core.action.DBActionAlias;
import com.didi.carmate.dreambox.core.action.DBActionAliasItem;
import com.didi.carmate.dreambox.core.action.DBTraceAttr;
import com.didi.carmate.dreambox.core.action.DBTraceAttrItem;
import com.didi.carmate.dreambox.core.base.DBAction;
import com.didi.carmate.dreambox.core.base.DBCallback;
import com.didi.carmate.dreambox.core.base.DBCallbacks;
import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBNode;
import com.didi.carmate.dreambox.core.base.DBNodeRegistry;
import com.didi.carmate.dreambox.core.base.DBTemplate;
import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.bridge.DBOnEvent;
import com.didi.carmate.dreambox.core.bridge.DBSendEventCallback;
import com.didi.carmate.dreambox.core.constraint.render.DBChildren;
import com.didi.carmate.dreambox.core.constraint.render.DBRender;
import com.didi.carmate.dreambox.core.data.DBMeta;
import com.didi.carmate.dreambox.core.utils.DBLogger;
import com.didi.carmate.dreambox.wrapper.Wrapper;
import com.didi.carmate.dreambox.wrapper.inner.WrapperMonitor;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSyntaxException;

import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBNodeParser {
    private static final String KEY_NODE_COUNT = "node_count";
    private static final boolean DEBUG_PRINT_TREE_NODE = true;

    private final DBNodeRegistry mNodeRegistry;
    private final Map<String, String> mProguardMap = new HashMap<>();
    private Gson mGson;
    private DBContext mDBContext;

    // 性能统计
    private final Map<String, Integer> nodeStatistics = new HashMap<>(32);
    private final Map<String, Integer> nodeTypeCount = new HashMap<>(32);

    public DBNodeParser(DBNodeRegistry nodeRegistry) {
        mNodeRegistry = nodeRegistry;
    }

    public DBTemplate parser(DBContext dbContext, String templateJson) {
        mDBContext = dbContext;

        if (mGson == null) {
            mGson = new GsonBuilder()
                    .registerTypeAdapter(DBTemplate.class, new DBTemplateDeserializer())
                    .create();
        }
        // 初始化性能统计容器
        nodeStatistics.clear();
        nodeStatistics.put(KEY_NODE_COUNT, 0);
        Map<String, String> params = new HashMap<>();
        params.put("file_size", String.valueOf(templateJson.length()));

        // 解析模板
        WrapperMonitor.ReportStart reportStart = Wrapper.get(mDBContext.getAccessKey())
                .monitor()
                .start(mDBContext.getTemplateId(),
                        DBConstants.TRACE_PARSER_TEMPLATE,
                        WrapperMonitor.TRACE_NUM_ONCE);

        DBTemplate dbTemplate = null;
        try {
            dbTemplate = mGson.fromJson(templateJson, DBTemplate.class);
            // 上报模板详细信息
            for (String key : nodeStatistics.keySet()) {
                params.put(key, String.valueOf(nodeStatistics.get(key)));
            }
            // 上报各节点个数
            if (nodeTypeCount.size() > 0) {
                StringBuilder b = new StringBuilder();
                boolean isFirst = true;
                for (String key : nodeTypeCount.keySet()) {
                    if (isFirst) {
                        b.append(key).append(":").append(nodeTypeCount.get(key));
                        isFirst = false;
                    } else {
                        b.append(",").append(key).append(":").append(nodeTypeCount.get(key));
                    }
                }
                params.put("nodes", b.toString());
            }
            reportStart.stop().addAll(params).report();
        } catch (JsonSyntaxException e) {
            DBLogger.e(mDBContext, "json syntax error: " + templateJson);
//            Wrapper.get(accessKey).monitor().crash(e);
        }
        return dbTemplate;
    }

    private class DBTemplateDeserializer implements JsonDeserializer<DBTemplate> {
        @Override
        public DBTemplate deserialize(JsonElement json, Type type, JsonDeserializationContext context) throws JsonParseException {
            spaceNum++;

            JsonObject jsonObject = json.getAsJsonObject();
            JsonElement jsonElementMap = jsonObject.get(DBConstants.T_MAP_NODE_NAME);
            JsonElement jsonElementIds = jsonObject.get(DBConstants.T_IDS_NODE_NAME);

            DBTemplate dbTemplate = new DBTemplate(mDBContext);
            if (null == jsonElementMap && null == jsonElementIds) {
                looperCreateNode(jsonObject, dbTemplate);
            } else { // 包含混淆节点
                // 压缩隐射表构建
                if (null != jsonElementMap) {
                    JsonObject jsonObjectMap = jsonElementMap.getAsJsonObject();
                    for (Map.Entry<String, JsonElement> entry : jsonObjectMap.entrySet()) {
                        mProguardMap.put(entry.getKey(), entry.getValue().getAsString());
                    }
                }
                // IDS映射表构建
                if (null != jsonElementIds) {
                    JsonObject jsonObjectIds = jsonElementIds.getAsJsonObject();
                    for (Map.Entry<String, JsonElement> entry : jsonObjectIds.entrySet()) {
                        mDBContext.putViewId(entry.getKey(), entry.getValue().getAsInt());
                    }
                }
                // 重新构建去掉map对象的根节点
                JsonObject detachProguard = new JsonObject();
                detachProguard.add(DBConstants.T_ROOT_NODE_NAME, jsonObject.get(DBConstants.T_ROOT_NODE_NAME));
                looperCreateNode(detachProguard, dbTemplate);
            }

            spaceNum--;
            return dbTemplate;
        }
    }

    private void looperCreateNode(JsonObject jsonObject, @NonNull IDBNode parent) {
        Set<Map.Entry<String, JsonElement>> entries = jsonObject.entrySet();
        for (Map.Entry<String, JsonElement> entry : entries) {
            String tagName = getOriginKey(entry.getKey());
            JsonElement jsonElement = entry.getValue();

            String tagNamePrint = getBlankByNum(spaceNum) + "tag name: " + tagName;
            if (jsonElement.isJsonPrimitive()) {
                JsonPrimitive jsonPrimitive = jsonElement.getAsJsonPrimitive();
                if (jsonPrimitive.isString()) {
                    printTreeNode(tagNamePrint + "  String Value: " + jsonPrimitive.getAsString() + " parent: " + parent.getTagName());
                    parent.putAttr(tagName, jsonPrimitive.getAsString());
                } else if (jsonPrimitive.isNumber()) {
                    printTreeNode(tagNamePrint + "  Number Value: " + jsonPrimitive.getAsString() + " parent: " + parent.getTagName());
                    parent.putAttr(tagName, jsonPrimitive.getAsString());
                } else {
                    printTreeNode(tagNamePrint + "  Ignore Value: " + jsonPrimitive);
                }
            } else if (jsonElement.isJsonObject()) {
                spaceNum++;
                printTreeNode(tagNamePrint + " value: JsonObject parent: " + parent.getTagName());

                JsonObject subJsonObject = jsonElement.getAsJsonObject();
                INodeCreator nodeCreator = mNodeRegistry.getNodeMap().get(tagName);
                if (null != nodeCreator) {
                    IDBNode node = nodeCreator.createNode(mDBContext);
                    node.setTagName(tagName);
                    node.setParent(parent);
                    parent.addChild(node);
                    collectNodeInfo(node, tagName); // 统计信息

                    if (node instanceof DBMeta) { // meta 节点特殊处理
                        DBMeta metaNode = (DBMeta) node;
                        Set<Map.Entry<String, JsonElement>> subEntries = subJsonObject.entrySet();
                        for (Map.Entry<String, JsonElement> subEntry : subEntries) {
                            String metaTagName = subEntry.getKey();
                            JsonElement metaJsonElement = subEntry.getValue();
                            // 单独处理
                            constructMeta(metaNode, metaTagName, metaJsonElement);
                        }
                    } else { // 其他节点继续递归
                        looperCreateNode(subJsonObject, node);
                    }
                } else {
                    reportUnexpectedNodeTag(parent, tagName);
                }
                spaceNum--;
            } else if (jsonElement.isJsonArray()) {
                printTreeNode(tagNamePrint + " value: JsonArray parent: " + parent.getTagName());

                // 创建数组根节点，作为数组子节点的parent
                IDBNode arrayNode;
                INodeCreator nodeCreator = mNodeRegistry.getNodeMap().get(tagName);
                if (null != nodeCreator) {
                    arrayNode = nodeCreator.createNode(mDBContext);
                    arrayNode.setTagName(tagName);
                    arrayNode.setParent(parent);
                    parent.addChild(arrayNode);
                    collectNodeInfo(arrayNode, tagName); // 统计信息
                } else {
                    reportUnexpectedNodeTag(parent, tagName);
                    return;
                }

                JsonArray jsonArray = jsonElement.getAsJsonArray();
                for (JsonElement element : jsonArray) {
                    if (element.isJsonObject()) {
                        spaceNum++;
                        printTreeNode(getBlankByNum(spaceNum) + "---------------");

                        JsonObject subJsonObject = element.getAsJsonObject();
                        if (arrayNode instanceof DBRender || arrayNode instanceof DBChildren) { // 视图数组节点
                            JsonElement typeElement = subJsonObject.get(getProguardKey());
                            if (null == typeElement) {
                                printTreeNode("type should not be null: " + subJsonObject);
                                return;
                            }

                            String viewTagName = typeElement.getAsString();
                            if (mNodeRegistry.getNodeMap().containsKey(viewTagName)) {
                                INodeCreator viewNodeCreator = mNodeRegistry.getNodeMap().get(viewTagName);
                                if (null != viewNodeCreator) {
                                    IDBNode node = viewNodeCreator.createNode(mDBContext);
                                    node.setTagName(viewTagName);
                                    arrayNode.addChild(node);
                                    // 这里的json结构，由于使用[type]作为类型标志，是平级的结构，所以特殊处理父子节点
                                    node.setParent(arrayNode); // 设置view节点的父节点
                                    collectNodeInfo(node, viewTagName); // 统计信息
                                    looperCreateNode(subJsonObject, node); // 这里的父节点是view 节点
                                } else {
                                    printTreeNode("can not find [NodeCreator] for key: " + viewTagName);
                                    reportUnexpectedNodeTag(arrayNode, viewTagName);
                                }
                            } else {
                                printTreeNode("unexpected key: " + viewTagName);
                            }
                        } else if (arrayNode instanceof DBCallbacks) { // callbacks 节点需特殊处理
                            JsonElement typeElement = subJsonObject.get(getProguardKey());
                            if (null == typeElement) {
                                printTreeNode("type should not be null: " + subJsonObject);
                                return;
                            }
                            String callbackTagName = typeElement.getAsString();
                            DBCallback node;
                            if ("onEvent".equals(callbackTagName)) {
                                node = new DBOnEvent(mDBContext);
                            } else if ("onSendEventCallback".equals(callbackTagName)) {
                                node = new DBSendEventCallback(mDBContext);
                            } else {
                                node = new DBCallback(mDBContext);
                            }
                            node.setTagName(callbackTagName);
                            arrayNode.addChild(node);
                            node.setParent(arrayNode);
                            looperCreateNode(subJsonObject, node); // 这里的父节点是view 节点
                        } else if (arrayNode instanceof DBTraceAttr) { // trace 的 attr节点需特殊处理
                            DBTraceAttrItem node = new DBTraceAttrItem(mDBContext);
                            node.setTagName("attr_item");
                            arrayNode.addChild(node);
                            node.setParent(arrayNode);
                            looperCreateNode(subJsonObject, node); // 这里的父节点是view 节点
                        } else if (arrayNode instanceof DBActionAlias) { // actionAlias 节点需特殊处理
                            DBActionAliasItem node = new DBActionAliasItem(mDBContext);
                            node.setTagName("alias_item");
                            arrayNode.addChild(node);
                            node.setParent(arrayNode);
                            looperCreateNode(subJsonObject, node); // 这里的父节点是view 节点
                        } else { // 其他数组节点
                            String elementTagName = getOriginKey(subJsonObject.keySet().iterator().next()); // 获取子节点的key
                            INodeCreator arrSubNodeCreator = mNodeRegistry.getNodeMap().get(elementTagName);
                            if (null != arrSubNodeCreator) {
                                IDBNode node = arrSubNodeCreator.createNode(mDBContext);
                                node.setTagName(elementTagName);
                                collectNodeInfo(node, elementTagName); // 统计信息
                                looperCreateNode(subJsonObject, arrayNode);
                            } else {
                                reportUnexpectedNodeTag(arrayNode, elementTagName);
                            }
                        }
                        spaceNum--;
                    } else {
                        printTreeNode(tagNamePrint + "  should not go here!!!!!!");
                    }
                }
            } else {
                printTreeNode("unexpected json element type: " + jsonElement);
            }
        }
    }

    private void constructMeta(DBMeta metaVNode, String metaTagName, JsonElement metaJsonElement) {
        String tagNamePrint = getBlankByNum(spaceNum) + "meta tag name: " + metaTagName;

        if (metaJsonElement.isJsonPrimitive()) {
            JsonPrimitive jsonPrimitive = metaJsonElement.getAsJsonPrimitive();
            if (jsonPrimitive.isString()) {
                printTreeNode(tagNamePrint + "  String Value: " + jsonPrimitive.getAsString() + " parent: meta");
                metaVNode.putAttr(metaTagName, jsonPrimitive.getAsString());
            } else if (jsonPrimitive.isNumber()) {
                printTreeNode(tagNamePrint + "  Number Value: " + jsonPrimitive.getAsString() + " parent: meta");
                metaVNode.putAttr(metaTagName, jsonPrimitive.getAsString());
            } else {
                printTreeNode(tagNamePrint + "  Ignore Value: " + jsonPrimitive);
            }
        } else if (metaJsonElement.isJsonObject()) {
            printTreeNode(tagNamePrint + " value: JsonObject parent: meta");
            metaVNode.putJsonObject(metaTagName, metaJsonElement.getAsJsonObject());
        } else if (metaJsonElement.isJsonArray()) {
            printTreeNode(tagNamePrint + " value: JsonArray parent: meta");
            metaVNode.putJsonArray(metaTagName, metaJsonElement.getAsJsonArray());
        } else {
            printTreeNode("unexpected json element type: " + metaJsonElement);
        }
    }

    private String getBlankByNum(int num) {
        StringBuilder str = new StringBuilder();
        for (int i = 0; i < num; i++) {
            str.append("    ");
        }
        return str.toString();
    }

    private String getOriginKey(String proguardKey) {
        if (mProguardMap.containsKey(proguardKey)) {
            return mProguardMap.get(proguardKey);
        }
        return proguardKey;
    }

    private String getProguardKey() {
        for (Map.Entry<String, String> entry : mProguardMap.entrySet()) {
            if (entry.getValue().equals(DBNode.KEY_NODE_TYPE)) {
                return entry.getKey();
            }
        }
        return DBNode.KEY_NODE_TYPE;
    }

    private void collectNodeInfo(IDBNode node, String originKey) {
        // 节点数据统计
        if (node instanceof DBAction || node instanceof DBBaseView) {
            statisticNode(nodeStatistics, nodeTypeCount, originKey);
        }
    }

    private void reportUnexpectedNodeTag(IDBNode parent, String tagName) {
        printTreeNode("can not find [NodeCreator] for key: " + tagName);
        Map<String, String> map = new HashMap<>();
        map.put("parent_node", parent.getTagName());
        map.put("node_name", tagName);
        Wrapper.get(mDBContext.getAccessKey()).monitor()
                .report(mDBContext.getTemplateId(), DBConstants.TRACE_NODE_UNKNOWN, WrapperMonitor.TRACE_NUM_EVERY)
                .addAll(map).report();
    }

    private void statisticNode(Map<String, Integer> statisticMap, Map<String, Integer> nodeTypeCount, String originKey) {
        Integer nodeCount = statisticMap.get(KEY_NODE_COUNT);
        statisticMap.put(KEY_NODE_COUNT, (null == nodeCount) ? 0 : nodeCount + 1);
        Integer count = nodeTypeCount.get(originKey);
        if (null != count) {
            nodeTypeCount.put(originKey, count + 1);
        } else {
            nodeTypeCount.put(originKey, 1);
        }
    }

    private int spaceNum = 0; // 用于格式化打印tree节点

    private void printTreeNode(String msg) {
        if (DEBUG_PRINT_TREE_NODE) {
            DBLogger.d(mDBContext, msg);
        }
    }
}
