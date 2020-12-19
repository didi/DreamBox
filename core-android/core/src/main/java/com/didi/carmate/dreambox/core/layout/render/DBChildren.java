package com.didi.carmate.dreambox.core.layout.render;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.layout.base.DBBindView;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBChildren extends DBBindView {
    public DBChildren(DBContext dbContext) {
        super(dbContext);
    }

    public static String getNodeTag() {
        return "children";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBChildren createNode(DBContext dbContext) {
            return new DBChildren(dbContext);
        }
    }
}
