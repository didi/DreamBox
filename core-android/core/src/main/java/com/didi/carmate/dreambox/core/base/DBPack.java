package com.didi.carmate.dreambox.core.base;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.render.view.DBRootView;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBPack extends DBViewGroup<DBRootView> {
    public DBPack(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public DBRootView onCreateView() {
        DBRootView packRootView = new DBRootView(mDBContext);
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
