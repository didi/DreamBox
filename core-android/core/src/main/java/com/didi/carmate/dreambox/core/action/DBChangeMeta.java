package com.didi.carmate.dreambox.core.action;

import com.didi.carmate.dreambox.core.base.DBAction;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.utils.DBLogger;
import com.didi.carmate.dreambox.core.utils.DBUtils;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBChangeMeta extends DBAction {
    private DBChangeMeta(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        String key = attrs.get("key");
        String value = attrs.get("value");

        if (DBUtils.isEmpty(value)) {
            DBLogger.e(mDBContext, "[value] is null");
            return;
        }

        if (DBUtils.isNumeric(value)) {
            mDBContext.changeIntValue(key, Integer.parseInt(value));
        } else if ("true".equals(value)) {
            mDBContext.changeBooleanValue(key, true);
        } else if ("false".equals(value)) {
            mDBContext.changeBooleanValue(key, false);
        } else {
            mDBContext.changeStringValue(key, value);
        }
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBChangeMeta createNode(DBContext dbContext) {
            return new DBChangeMeta(dbContext);
        }
    }

    public static String getNodeTag() {
        return "changeMeta";
    }
}