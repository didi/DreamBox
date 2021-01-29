package com.didi.carmate.dreambox.core.v4.action;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBModel;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.didi.carmate.dreambox.core.v4.utils.DBLogger;
import com.didi.carmate.dreambox.wrapper.v4.Toast;
import com.didi.carmate.dreambox.wrapper.v4.Wrapper;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBToast extends DBAction {
    private DBToast(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        doInvoke(attrs, null);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs, DBModel model) {
        final String src = getString(attrs.get("src"), model);
        final boolean isLong = getBoolean(attrs.get("long"), model);

        if (null == src) {
            DBLogger.e(mDBContext, "[src] is null.");
            return;
        }

        Toast toast = Wrapper.get(mDBContext.getAccessKey()).toast();
        toast.show(mDBContext.getContext(), src, isLong);
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBToast createNode(DBContext dbContext) {
            return new DBToast(dbContext);
        }
    }

    public static String getNodeTag() {
        return "toast";
    }
}
