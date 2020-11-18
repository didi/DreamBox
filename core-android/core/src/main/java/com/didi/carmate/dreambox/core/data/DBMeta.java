package com.didi.carmate.dreambox.core.data;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBNode;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBMeta extends DBNode {
    private final Map<String, JsonObject> jsonObjectMap = new HashMap<>();
    private final Map<String, JsonArray> jsonArrayMap = new HashMap<>();

    private DBMeta(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        // 将K/V放入DBDataPool
        Set<Map.Entry<String, String>> kvEntries = attrs.entrySet();
        for (Map.Entry<String, String> entry : kvEntries) {
            String value = entry.getValue();
            if (DBUtils.isNumeric(value)) {
                mDBContext.putIntValue(entry.getKey(), Integer.parseInt(value));
            } else if (value.equals("true")) {
                mDBContext.putBooleanValue(entry.getKey(), true);
            } else if (value.equals("false")) {
                mDBContext.putBooleanValue(entry.getKey(), false);
            } else {
                mDBContext.putStringValue(entry.getKey(), value);
            }
        }
        // 将JsonArray放入DBDataPool
        Set<Map.Entry<String, JsonObject>> objEntries = jsonObjectMap.entrySet();
        for (Map.Entry<String, JsonObject> entry : objEntries) {
            mDBContext.putJsonValue(entry.getKey(), entry.getValue());
        }
        // 将JsonObject放入DBDataPool
        Set<Map.Entry<String, JsonArray>> arrEntries = jsonArrayMap.entrySet();
        for (Map.Entry<String, JsonArray> entry : arrEntries) {
            mDBContext.putJsonArray(entry.getKey(), entry.getValue());
        }
    }

    public void putJsonObject(String key, JsonObject jsonObject) {
        jsonObjectMap.put(key, jsonObject);
    }

    public void putJsonArray(String key, JsonArray jsonArray) {
        jsonArrayMap.put(key, jsonArray);
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBMeta createNode(DBContext dbContext) {
            return new DBMeta(dbContext);
        }
    }

    public static String getNodeTag() {
        return "meta";
    }
}
