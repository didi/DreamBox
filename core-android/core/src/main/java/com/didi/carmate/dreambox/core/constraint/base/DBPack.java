package com.didi.carmate.dreambox.core.constraint.base;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.constraint.render.view.DBConstraintView;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBPack extends DBViewGroup<DBConstraintView> {
    public DBPack(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public DBConstraintView onCreateView() {
        DBConstraintView packRootView = new DBConstraintView(mDBContext);
        ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
        packRootView.setLayoutParams(lp);
        return packRootView;
    }

    public static String getNodeTag() {
        return "pack";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBPack createNode(DBContext dbContext) {
            return new DBPack(dbContext);
        }
    }
}
