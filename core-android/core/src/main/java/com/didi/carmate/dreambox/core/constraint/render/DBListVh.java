package com.didi.carmate.dreambox.core.constraint.render;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.constraint.base.DBContainer;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.constraint.render.view.list.DBListItemRoot;

import java.util.Map;

import static com.didi.carmate.dreambox.core.base.DBConstants.LIST_ORIENTATION_H;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBListVh extends DBContainer<DBListItemRoot> {
    private DBListVh(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public DBListItemRoot onCreateView() {
        Map<String, String> attrs = getParentAttrs();
        DBListItemRoot itemView = new DBListItemRoot(mDBContext);
        ViewGroup.LayoutParams lp;
        String orientation = attrs.get("orientation");
        if (LIST_ORIENTATION_H.equals(orientation)) {
            lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
        } else {
            lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        }
        itemView.setLayoutParams(lp);
        return itemView;
    }

    public static String getNodeTag() {
        return "vh";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBListVh createNode(DBContext dbContext) {
            return new DBListVh(dbContext);
        }
    }
}
