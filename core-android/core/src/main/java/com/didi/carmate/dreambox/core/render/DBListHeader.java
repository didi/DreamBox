package com.didi.carmate.dreambox.core.render;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContainer;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.render.view.DBRootView;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBListHeader extends DBContainer<DBRootView> {
    private DBListHeader(DBContext dbContext) {
        super(dbContext);
    }

    public static String getNodeTag() {
        return "header";
    }

    @Override
    public DBRootView onCreateView() {
        Map<String, String> attrs = getParentAttrs();
        DBRootView headerView = new DBRootView(mDBContext);
        ViewGroup.LayoutParams lp;
        String orientation = attrs.get("orientation");
        if (DBConstants.LIST_ORIENTATION_H.equals(orientation)) {
            lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
        } else {
            lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        }
        headerView.setLayoutParams(lp);
        return headerView;
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBListHeader createNode(DBContext dbContext) {
            return new DBListHeader(dbContext);
        }
    }
}
