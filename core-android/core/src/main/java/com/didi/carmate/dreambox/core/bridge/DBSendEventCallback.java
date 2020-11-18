package com.didi.carmate.dreambox.core.bridge;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.base.DBCallback;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/10/26
 */
public class DBSendEventCallback extends DBCallback {
    private String msgTo;

    public DBSendEventCallback(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        msgTo = attrs.get("msgTo");
    }

    public String getMsgTo() {
        return msgTo;
    }

    public static String getNodeTag() {
        return "onSendEventCallback";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBSendEventCallback createNode(DBContext dbContext) {
            return new DBSendEventCallback(dbContext);
        }
    }
}
