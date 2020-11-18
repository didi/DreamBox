package com.didi.carmate.dreambox.core.render;

import com.didi.carmate.dreambox.core.base.DBContainer;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.render.view.DBRootView;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBRender extends DBContainer<DBRootView> {
    private DBRootView rootView;

    private DBRender(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void bindView(DBRootView rootView) {
        super.bindView(rootView);

        this.rootView = rootView;
    }

    @Override
    public DBRootView onCreateView() {
        return rootView;
    }

    public static String getNodeTag() {
        return "render";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBRender createNode(DBContext dbContext) {
            return new DBRender(dbContext);
        }
    }
}
