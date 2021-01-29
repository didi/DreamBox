package com.didi.carmate.dreambox.core.v4.bridge;

import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBNode;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

import java.util.Map;
import java.util.Set;

/**
 * author: chenjing
 * date: 2020/10/26
 */
public class DBSendEventMsg extends DBNode {
    private JsonObject jsonObject;

    public DBSendEventMsg(DBContext dbContext) {
        super(dbContext);
    }

    public void doInvoke(Map<String, String> attrs) {
        jsonObject = new JsonObject();
        Set<Map.Entry<String, String>> entries = attrs.entrySet();
        for (Map.Entry<String, String> entry : entries) {
            String value = getString(entry.getValue(), null);
            jsonObject.add(entry.getKey(), new JsonPrimitive(value));
        }
    }

    public JsonObject getJsonObject() {
        return jsonObject;
    }

    public static String getVNodeTag() {
        return "msg";
    }

    public static class VNodeCreator implements INodeCreator {
        @Override
        public DBSendEventMsg createNode(DBContext dbContext) {
            return new DBSendEventMsg(dbContext);
        }
    }
}
