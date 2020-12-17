package com.didi.carmate.dreambox.core.yoga.render;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.yoga.base.DBContainer;
import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBRender extends DBContainer<DBYogaView> {
    private DBYogaView rootView;

    private DBRender(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void bindView(DBYogaView rootView) {
        super.bindView(rootView);

        this.rootView = rootView;
    }

    @Override
    public DBYogaView onCreateView() {
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
