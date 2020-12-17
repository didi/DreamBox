package com.didi.carmate.dreambox.core.constraint.render;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.constraint.base.DBContainer;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.constraint.render.view.DBConstraintView;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBListFooter extends DBContainer<DBConstraintView> {
    private DBListFooter(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public DBConstraintView onCreateView() {
        Map<String, String> attrs = getParentAttrs();
        DBConstraintView footView = new DBConstraintView(mDBContext);
        ViewGroup.LayoutParams lp;
        String orientation = attrs.get("orientation");
        if (DBConstants.LIST_ORIENTATION_H.equals(orientation)) {
            lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
        } else {
            lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        }
        footView.setLayoutParams(lp);
        return footView;
    }

    public static String getNodeTag() {
        return "footer";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBListFooter createNode(DBContext dbContext) {
            return new DBListFooter(dbContext);
        }
    }
}
