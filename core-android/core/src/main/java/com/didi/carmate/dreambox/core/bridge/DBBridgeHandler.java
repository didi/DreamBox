package com.didi.carmate.dreambox.core.bridge;

import com.didi.carmate.dreambox.core.action.IDBAction;
import com.didi.carmate.dreambox.core.base.DBAction;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBTemplate;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/7/15
 */
public class DBBridgeHandler {
    private final Map<String, IDBEventReceiver> eventReceiverMap = new HashMap<>();
    private final DBContext dbContext;

    public DBBridgeHandler(DBContext dbContext) {
        this.dbContext = dbContext;
    }

    public void registerEventReceiver(String eid, IDBEventReceiver eventReceiver) {
        if (!eventReceiverMap.containsKey(eid)) {
            eventReceiverMap.put(eid, eventReceiver);
        }
    }

    public void unRegisterEventReceiver(String eid) {
        eventReceiverMap.remove(eid);
    }

    public void nativeInvokeDb(String eid, String eventData) {
        DBTemplate dbTemplate = dbContext.getDBTemplate();
        DBOnEvent onEvent = dbTemplate.getDBOnEvent();
        if (null != onEvent && onEvent.getEid() != null && onEvent.getEid().equals(eid)) {
            String key = onEvent.getMsgTo();
            if (!DBUtils.isEmpty(key)) {
                if (eventData.startsWith("{") && eventData.endsWith("}")) { // 传递json对象字符串
                    dbContext.setExtJsonObject(key, new Gson().fromJson(eventData, JsonObject.class));
                } else {
                    dbContext.putStringValue(key, eventData); // 兼容传递普通字符串
                }
            }

            List<DBAction> actions = onEvent.getActionNodes();
            for (IDBAction action : actions) {
                action.invoke();
            }
        }
    }

    void dbInvokeNative(DBSendEvent sendEvent, String eid, JsonObject msg) {
        dbInvokeNative(sendEvent, eid, msg, null);
    }

    void dbInvokeNative(final DBSendEvent sendEvent, String eid, JsonObject msg, final DBSendEventCallback dbToNativeCallback) {
        IDBEventReceiver eventReceiver = eventReceiverMap.get(eid);
        if (null != eventReceiver) {
            if (null == dbToNativeCallback) {
                eventReceiver.onEvent(msg, null);
            } else {
                eventReceiver.onEvent(msg, new IDBEventReceiver.Callback() {
                    @Override
                    public void onCallback(String msgTo) {
                        String key = dbToNativeCallback.getMsgTo();
                        if (!DBUtils.isEmpty(key)) {
                            dbContext.setExtJsonObject(key, new Gson().fromJson(msgTo, JsonObject.class));
                        }
                        sendEvent.onCallback(); // action invoke
                    }
                });
            }
        }
    }
}
