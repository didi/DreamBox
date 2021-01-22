package com.didi.carmate.dreambox.core.v4.action;

import android.view.View;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.didi.carmate.dreambox.core.v4.utils.DBLogger;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;
import com.didi.carmate.dreambox.wrapper.v4.Storage;
import com.didi.carmate.dreambox.wrapper.v4.Wrapper;

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
        doInvoke(attrs, null);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs, View view) {
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