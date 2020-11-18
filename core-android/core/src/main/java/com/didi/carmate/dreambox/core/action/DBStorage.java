package com.didi.carmate.dreambox.core.action;

import com.didi.carmate.dreambox.core.base.DBAction;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.utils.DBLogger;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.didi.carmate.dreambox.wrapper.Storage;
import com.didi.carmate.dreambox.wrapper.Wrapper;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBStorage extends DBAction {
    private DBStorage(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        final String key = attrs.get("key");
        final String write = attrs.get("write");
        final String readTo = attrs.get("readTo");

        if (null == key) {
            DBLogger.e(mDBContext, "[key] is null.");
            return;
        }

        Storage storage = Wrapper.get(mDBContext.getAccessKey()).storage();
        if (!DBUtils.isEmpty(write)) {
            storage.put(key, write);
        } else if (!DBUtils.isEmpty(readTo)) {
            String value = storage.get(key, "");
            mDBContext.putStringValue(readTo, value);
        } else {
            Wrapper.get(mDBContext.getAccessKey()).log().e("[write] or [readTo] all null is not expected");
        }
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBStorage createNode(DBContext dbContext) {
            return new DBStorage(dbContext);
        }
    }

    public static String getNodeTag() {
        return "storage";
    }
}