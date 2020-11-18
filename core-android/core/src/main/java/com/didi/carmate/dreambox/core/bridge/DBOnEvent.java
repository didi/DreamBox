package com.didi.carmate.dreambox.core.bridge;

import com.didi.carmate.dreambox.core.base.DBCallback;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/7/15
 */
public class DBOnEvent extends DBCallback {
    private String eid;
    private String msgTo;

    private DBOnEvent(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        eid = attrs.get("eid");
        msgTo = attrs.get("msgTo");
    }

    public String getEid() {
        return eid;
    }

    public String getMsgTo() {
        return msgTo;
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBOnEvent createNode(DBContext dbContext) {
            return new DBOnEvent(dbContext);
        }
    }

    public static String getNodeTag() {
        return "onEvent";
    }
}
