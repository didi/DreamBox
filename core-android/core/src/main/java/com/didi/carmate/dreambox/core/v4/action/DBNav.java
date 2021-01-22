package com.didi.carmate.dreambox.core.v4.action;

import android.view.View;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.didi.carmate.dreambox.core.v4.utils.DBLogger;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;
import com.didi.carmate.dreambox.wrapper.v4.Navigator;
import com.didi.carmate.dreambox.wrapper.v4.Wrapper;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBNav extends DBAction {
    private DBNav(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        doInvoke(attrs, null);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs, View view) {
        String schema = getString(attrs.get("schema"));

        if (DBUtils.isEmpty(schema)) {
            DBLogger.e(mDBContext, "[schema] is null.");
            return;
        }

        Navigator nav = Wrapper.get(mDBContext.getAccessKey()).navigator();
        nav.navigator(mDBContext.getContext(), schema);
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBNav createNode(DBContext dbContext) {
            return new DBNav(dbContext);
        }
    }

    public static String getNodeTag() {
        return "nav";
    }
}