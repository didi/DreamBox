package com.didi.carmate.dreambox.core.v4.base;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.RestrictTo;

import com.didi.carmate.dreambox.core.v4.data.DBGlobalPool;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;
import com.didi.carmate.dreambox.wrapper.v4.Wrapper;
import com.didi.carmate.dreambox.wrapper.v4.inner.WrapperMonitor;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * author: chenjing
 * date: 2020/4/30
 * 提供节点接口的默认实现，同时提供节点通用的处理方法，如数据源占位替换相关方法<br/><br/>
 *
 * <h2>生命周期定义</h2>
 * <p>callback</p>
 * protected void onParserAttribute(Map<String, String> attrs);<br/>
 * protected void onParserNode();<br/>
 * protected void onParserNodeFinished(Map<String, String> attrs);<br/>
 *
 * <p>action</p>
 * protected void onParserAttribute(Map<String, String> attrs);<br/>
 * protected void onParserNode();<br/>
 * protected void onParserNodeFinished(Map<String, String> attrs);<br/>
 * ------------------------<br/>
 * doInvoke(Map<String, String> attrs);<br/>
 *
 * <p>view</p>
 * protected void onParserAttribute(Map<String, String> attrs);<br/>
 * protected void onParserNode();<br/>
 * protected void onParserNodeFinished(Map<String, String> attrs);<br/>
 * ------callback和action节点作为视图节点的基础能力，需要先解析完毕再开始自己特有的生命周期-----<br/>
 * protected abstract V onCreateView();<br/>
 * protected void onAttributesBind(Map<String, String> attrs);<br/>
 * protected void onCallbackBind(List<DBCallback> callbacks);
 */
public abstract class DBNode implements IDBNode {
    private String tagName;
    private final Map<String, String> attrs = new HashMap<>();
    private IDBNode parent;
    private final List<IDBNode> children = new ArrayList<>();
    private static final String ARR_TAG_START = "`";
    private static final String ARR_TAG_END = "``";

    protected DBContext mDBContext;

    protected DBNode(DBContext dbContext) {
        this.mDBContext = dbContext;
    }

    @Override
    public String getTagName() {
        return tagName;
    }

    @Override
    public void setTagName(String tagName) {
        this.tagName = tagName;
    }

    /**
     * 获取节点所有属性，禁止外部类直接访问
     */
    @RestrictTo(RestrictTo.Scope.LIBRARY)
    public Map<String, String> getAttrs() {
        return attrs;
    }

    @Override
    public void putAttr(String key, String value) {
        attrs.put(key, value);
    }

    @Override
    public void setParent(IDBNode parent) {
        this.parent = parent;
    }

    @Override
    public IDBNode getParent() {
        return parent;
    }

    @Override
    public void addChild(IDBNode child) {
        children.add(child);
    }

    @Override
    public List<IDBNode> getChildren() {
        return children;
    }

    @CallSuper
    @Override
    public void parserAttribute() {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            child.parserAttribute();
        }

        onParserAttribute(getAttrs());
    }

    @CallSuper
    @Override
    public void parserNode() {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            child.parserNode();
        }

        onParserNode();
    }

    @CallSuper
    @Override
    public void finishParserNode() {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            child.finishParserNode();
        }

        onParserNodeFinished();
    }

    @CallSuper
    protected void onParserAttribute(Map<String, String> attrs) {

    }

    @CallSuper
    protected void onParserNode() {

    }

    @CallSuper
    protected void onParserNodeFinished() {

    }

    @Override
    public void release() {

    }

    /**
     * 根据给定的key拿String数据
     */
    protected String getString(String rawKey) {
        return getString(rawKey, null);
    }

    /**
     * 根据给定的key拿String数据
     */
    protected String getString(String rawKey, DBModel model) {
        if (DBUtils.isEmpty(rawKey)) {
            return "";
        }

        rawKey = rawKey.replace("[", ARR_TAG_START);
        rawKey = rawKey.replace("]", ARR_TAG_END);

        Pattern p = Pattern.compile("\\$\\{[\\w\\.\\`]+\\}");
        Matcher m = p.matcher(rawKey);
        List<String> variableList = new ArrayList<>();
        while (m.find()) {
            if (!variableList.contains(m.group())) {
                variableList.add(m.group());
            }
        }
        for (int i = 0; i < variableList.size(); i++) {
            if (null == model || null == model.getData()) {
                rawKey = rawKey.replace(variableList.get(i), getSingleString(variableList.get(i)));
            } else {
                rawKey = rawKey.replace(variableList.get(i), getSingleStringWithData(variableList.get(i), model.getData()));
            }
        }
        return rawKey;
    }

    // 数组获取临时实现，待重构
    private String getSingleString(String rawKey) {
        // 尝试从meta、global pool、ext里拿
        if (rawKey.startsWith("${") && rawKey.endsWith("}")) {
            String variable = rawKey.substring(2, rawKey.length() - 1);
            String[] keys = variable.split("\\.");
            // 全局对象池只支持简单的KV对，不支持多级对象
            if (keys[0].equals(DBConstants.DATA_GLOBAL_PREFIX)) {
                return DBGlobalPool.get(mDBContext.getAccessKey()).getData(keys[1], String.class);
            }
            if (keys.length == 1) {
                return mDBContext.getStringValue(keys[0]);
            }

            JsonElement element;
            if (keys[0].equals(DBConstants.DATA_EXT_PREFIX)) {
                String[] keysExt = new String[keys.length - 1];
                System.arraycopy(keys, 1, keysExt, 0, keysExt.length);
                element = getJsonElement(keysExt, mDBContext.getJsonValue(DBConstants.DATA_EXT_PREFIX));
            } else {
                element = getJsonElement(keys, mDBContext.getJsonValue(keys[0]));
            }

            if (null != element && element.isJsonPrimitive()) {
                return element.getAsJsonPrimitive().getAsString();
            } else {
                if (Wrapper.getInstance().debug) {
                    Wrapper.get(mDBContext.getAccessKey()).log().e("check rawKey: " + rawKey);
                } else {
                    reportParserDataFail();
                }
                return "";
            }
        }
        return rawKey;
    }

    /**
     * 根据给定的key从给定的字典数据源里拿String数据
     */
    private String getSingleStringWithData(String rawKey, @NonNull JsonObject dict) {
        if (rawKey.startsWith("${") && rawKey.endsWith("}")) {
            String variable = rawKey.substring(2, rawKey.length() - 1);

            String[] keys = variable.split("\\.");
            JsonElement element = getJsonElement(keys, dict);
            if (null != element && element.isJsonPrimitive()) {
                return element.getAsJsonPrimitive().getAsString();
            } else {
                if (Wrapper.getInstance().debug) {
                    Wrapper.get(mDBContext.getAccessKey()).log().e("check rawKey: " + rawKey);
                } else {
                    reportParserDataFail();
                }
                return "";
            }
        }
        return rawKey;
    }

    protected boolean getBoolean(String rawKey) {
        return getBoolean(rawKey, null);
    }

    /**
     * 根据给定的key拿boolean数据
     */
    protected boolean getBoolean(String rawKey, DBModel model) {
        if (DBUtils.isEmpty(rawKey)) {
            return false;
        }

        // 尝试从meta、global pool、ext里拿
        if (rawKey.startsWith("${") && rawKey.endsWith("}")) {
            rawKey = rawKey.replace("[", ARR_TAG_START);
            rawKey = rawKey.replace("]", ARR_TAG_END);

            String variable = rawKey.substring(2, rawKey.length() - 1);
            String[] keys = variable.split("\\.");
            // 全局对象池只支持简单的KV对，不支持多级对象
            if (keys[0].equals(DBConstants.DATA_GLOBAL_PREFIX)) {
                return DBGlobalPool.get(mDBContext.getAccessKey()).getData(keys[1], Boolean.class);
            }
            if (keys.length == 1) {
                return mDBContext.getBooleanValue(variable);
            }

            JsonElement element;
            if (keys[0].equals(DBConstants.DATA_EXT_PREFIX)) {
                String[] keysExt = new String[keys.length - 1];
                System.arraycopy(keys, 1, keysExt, 0, keysExt.length);
                element = getJsonElement(keysExt, mDBContext.getJsonValue(DBConstants.DATA_EXT_PREFIX));
            } else {
                element = getJsonElement(keys, mDBContext.getJsonValue(keys[0]));
            }

            if (null != element && element.isJsonPrimitive()) {
                return element.getAsString().equals("true");
            }
        }
        return "true".equals(rawKey);
    }

    protected int getInt(String rawKey) {
        return getInt(rawKey, null);
    }

    /**
     * 根据给定的key从data pool里拿int数据
     */
    protected int getInt(String rawKey, DBModel model) {
        if (DBUtils.isEmpty(rawKey)) {
            return -1;
        }

        if (DBUtils.isNumeric(rawKey)) {
            return Integer.parseInt(rawKey);
        }

        // 尝试从meta、global pool、ext里拿
        if (rawKey.startsWith("${") && rawKey.endsWith("}")) {
            String variable = rawKey.substring(2, rawKey.length() - 1);
            String[] keys = variable.split("\\.");
            // 全局对象池只支持简单的KV对，不支持多级对象
            if (keys[0].equals(DBConstants.DATA_GLOBAL_PREFIX)) {
                return DBGlobalPool.get(mDBContext.getAccessKey()).getData(keys[1], Integer.class);
            }
            if (keys.length == 1) {
                return mDBContext.getIntValue(variable);
            }

            JsonElement element;
            if (keys[0].equals(DBConstants.DATA_EXT_PREFIX)) {
                String[] keysExt = new String[keys.length - 1];
                System.arraycopy(keys, 1, keysExt, 0, keysExt.length);
                element = getJsonElement(keysExt, mDBContext.getJsonValue(DBConstants.DATA_EXT_PREFIX));
            } else {
                element = getJsonElement(keys, mDBContext.getJsonValue(keys[0]));
            }

            if (null != element && element.isJsonPrimitive()) {
                return element.getAsInt();
            }
        }
        return -1;
    }

    protected JsonObject getJsonObject(String rawKey) {
        return getJsonObject(rawKey, null);
    }

    /**
     * 根据给定的key从meta数据源里拿json对象
     */
    protected JsonObject getJsonObject(String rawKey, DBModel model) {
        if (DBUtils.isEmpty(rawKey)) {
            return null;
        }
        rawKey = rawKey.replace("[", ARR_TAG_START);
        rawKey = rawKey.replace("]", ARR_TAG_END);

        if (rawKey.startsWith("${") && rawKey.endsWith("}")) {
            String variable = rawKey.substring(2, rawKey.length() - 1);
            String[] keys = variable.split("\\.");
            JsonElement element;
            if (null != model && null != model.getData()) {
                element = getJsonElement(keys, model.getData());
            } else {
                element = getJsonElement(keys, mDBContext.getJsonValue(keys[0]));
            }
            if (null != element && element.isJsonObject()) {
                return element.getAsJsonObject();
            }
        }
        return null;
    }

    protected List<JsonObject> getJsonObjectList(String rawKey) {
        List<JsonObject> jsonObjects = new ArrayList<>();

        if (!DBUtils.isEmpty(rawKey) && rawKey.startsWith("${") && rawKey.endsWith("}")) {
            rawKey = rawKey.replace("[", ARR_TAG_START);
            rawKey = rawKey.replace("]", ARR_TAG_END);

            JsonArray jsonArray = null;
            String variable = rawKey.substring(2, rawKey.length() - 1);
            String[] keys = variable.split("\\.");
            if (keys.length == 1) {
                jsonArray = mDBContext.getJsonArray(variable);
            } else {
                String[] keysExt = new String[keys.length - 1];
                System.arraycopy(keys, 1, keysExt, 0, keysExt.length);
                JsonElement element = getJsonElement(keysExt, mDBContext.getJsonValue(keys[0]));
                if (element.isJsonArray()) {
                    jsonArray = element.getAsJsonArray();
                }
            }
            // 添加到数组
            if (jsonArray != null) {
                for (JsonElement jsonElement : jsonArray) {
                    if (jsonElement instanceof JsonObject) {
                        jsonObjects.add((JsonObject) jsonElement);
                    }
                }
            }
        }
        return jsonObjects;
    }

    private JsonElement getJsonElement(String[] arrKeys, JsonElement jsonElement) {
        if (null == arrKeys || arrKeys.length == 0 || null == jsonElement) {
            return null;
        }

        int i = 0;
        while (i < arrKeys.length) {
            if (isJsonArrayKey(arrKeys[i])) {
                JsonArrayKey jsonArrayKey = getJsonArrayKey(arrKeys[i]);
                JsonElement tmpElement = jsonElement.getAsJsonObject().get(jsonArrayKey.key);
                if (checkJsonArray(tmpElement, jsonArrayKey.pos)) {
                    jsonElement = tmpElement.getAsJsonArray().get(jsonArrayKey.pos);
                } else {
                    return null;
                }
            } else {
                jsonElement = jsonElement.getAsJsonObject().get(arrKeys[i]);
            }
            if (null == jsonElement) {
                return null;
            }
            i++;
        }
        return jsonElement;
    }

    private JsonArrayKey getJsonArrayKey(String rawArrayKey) {
        JsonArrayKey arrayKey = new JsonArrayKey();
        int tagStart = rawArrayKey.indexOf(ARR_TAG_START);
        int tagEnd = rawArrayKey.indexOf(ARR_TAG_END);
        String strPos = rawArrayKey.substring(tagStart + 1, tagEnd);
        arrayKey.key = rawArrayKey.substring(0, tagStart);
        arrayKey.pos = Integer.parseInt(strPos);
        return arrayKey;
    }

    private boolean checkJsonArray(JsonElement element, int pos) {
        if (null == element) {
            Wrapper.get(mDBContext.getAccessKey()).log().e("element is null");
            return false;
        } else if (!element.isJsonArray()) {
            Wrapper.get(mDBContext.getAccessKey()).log().e("element is not JsonArray");
            return false;
        } else if (element.getAsJsonArray().size() <= pos) {
            Wrapper.get(mDBContext.getAccessKey()).log().e("index large than array size");
            return false;
        }
        return true;
    }

    private boolean isJsonArrayKey(String rawArrayKey) {
        return rawArrayKey.contains(ARR_TAG_START) && rawArrayKey.contains(ARR_TAG_END);
    }

    private void reportParserDataFail() {
        Wrapper.get(mDBContext.getAccessKey()).monitor().report(
                mDBContext.getTemplateId(),
                DBConstants.TRACE_PARSER_DATA_FAIL,
                WrapperMonitor.TRACE_NUM_ONCE
        );
    }

    private static class JsonArrayKey {
        int pos = -1;
        String key = "";
    }
}
