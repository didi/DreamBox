package com.didi.carmate.dreambox.core.action;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBNode;
import com.didi.carmate.dreambox.core.base.INodeCreator;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBActions extends DBNode {
    private DBActions(DBContext dbContext) {
        super(dbContext);
    }

    public static String getNodeTag() {
        return "actions";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBActions createNode(DBContext dbContext) {
            return new DBActions(dbContext);
        }
    }
}
