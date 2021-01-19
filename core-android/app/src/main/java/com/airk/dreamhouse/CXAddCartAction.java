package com.airk.dreamhouse;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;

import java.util.Map;

public class CXAddCartAction extends DBAction {
    private CXAddCartAction(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        final String src = getString(attrs.get("src"));
//        final boolean isLong = getBoolean(attrs.get("long"));
//
//        if (null == src) {
//            DBLogger.e(mDBContext, "[src] is null.");
//            return;
//        }
//
//        Toast toast = Wrapper.get(mDBContext.getAccessKey()).toast();
//        toast.show(mDBContext.getContext(), src, isLong);
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public CXAddCartAction createNode(DBContext dbContext) {
            return new CXAddCartAction(dbContext);
        }
    }

    public static String getNodeTag() {
        return "addCartAction";
    }
}
