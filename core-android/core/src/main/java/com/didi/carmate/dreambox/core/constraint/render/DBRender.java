package com.didi.carmate.dreambox.core.constraint.render;

import com.didi.carmate.dreambox.core.constraint.base.DBContainer;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.constraint.render.view.DBConstraintView;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBRender extends DBContainer<DBConstraintView> {
    private DBConstraintView rootView;

    private DBRender(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void bindView(DBConstraintView rootView) {
        super.bindView(rootView);

        this.rootView = rootView;
    }

    @Override
    public DBConstraintView onCreateView() {
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
