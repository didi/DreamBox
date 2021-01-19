package com.didi.carmate.dreambox.core.v4.bridge;

import com.didi.carmate.dreambox.core.v4.base.DBCallback;
import com.didi.carmate.dreambox.core.v4.base.DBContext;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/7/15
 */
public class DBOnEvent extends DBCallback {
    private String eid;
    private String msgTo;

    public DBOnEvent(DBContext dbContext) {
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
}
