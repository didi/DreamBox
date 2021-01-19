package com.didi.carmate.dreambox.core.v4.bridge;

import com.didi.carmate.dreambox.core.v4.action.DBActionWithCallback;
import com.didi.carmate.dreambox.core.v4.action.IDBAction;
import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBCallbacks;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.IDBNode;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;

import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/7/15
 */
public class DBSendEvent extends DBActionWithCallback {
    private DBSendEventMsg sendEventMsg;
    private DBSendEventCallback eventCallback;

    private DBSendEvent(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void onParserNode() {
        super.onParserNode();

        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof DBSendEventMsg) {
                sendEventMsg = (DBSendEventMsg) child;
            } else if (child instanceof DBCallbacks) {
                List<IDBNode> callbacks = child.getChildren();
                for (IDBNode callback : callbacks) {
                    if ("onSendEventCallback".equals(callback.getTagName())) {
                        eventCallback = (DBSendEventCallback) callback;
                    }
                }
            }
        }
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        String eid = attrs.get("eid");

        DBBridgeHandler bridgeHandler = mDBContext.getBridgeHandler();
        if (null != sendEventMsg) {
            sendEventMsg.doInvoke(attrs); // 解析出子节点的数据，用于构建JsonObject作为event参数传递给native
        }
        if (null == eventCallback) {
            bridgeHandler.dbInvokeNative(this, eid,
                    (null != sendEventMsg) ? sendEventMsg.getJsonObject() : null);
        } else {
            bridgeHandler.dbInvokeNative(this, eid,
                    (null != sendEventMsg) ? sendEventMsg.getJsonObject() : null,
                    eventCallback);
        }
    }

    public void onCallback() {
        List<DBAction> actions = eventCallback.getActionNodes();
        if (null != actions) {
            for (IDBAction action : actions) {
                action.invoke();
            }
        }
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBSendEvent createNode(DBContext dbContext) {
            return new DBSendEvent(dbContext);
        }
    }

    public static String getNodeTag() {
        return "sendEvent";
    }
}
