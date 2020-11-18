package com.didi.carmate.dreambox.core.action;

import androidx.annotation.Nullable;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.wrapper.Net;
import com.didi.carmate.dreambox.wrapper.Wrapper;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBNet extends DBActionWithCallback {
    private DBNet(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        final String url = getString(attrs.get("url"));
        final String to = attrs.get("to");

        Net net = Wrapper.get(mDBContext.getAccessKey()).net();
        net.get(url, new Net.Callback() {
            @Override
            public void onSuccess(@Nullable String json) {
                try {
                    JsonObject jsonObject = new Gson().fromJson(json, JsonObject.class);
                    // 数据更新到数据池
                    if (null != to) {
                        mDBContext.putJsonValue(to, jsonObject);
                    }
                } catch (JsonSyntaxException e) {
                    Wrapper.get(mDBContext.getAccessKey()).log().e("not json String: " + json);
                    return;
                }

                doCallback("onSuccess", getCallbacks());
            }

            @Override
            public void onError(int httpCode, @Nullable Exception exception) {
                doCallback("onError", getCallbacks());
            }
        });
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBNet createNode(DBContext dbContext) {
            return new DBNet(dbContext);
        }
    }

    public static String getNodeTag() {
        return "net";
    }
}