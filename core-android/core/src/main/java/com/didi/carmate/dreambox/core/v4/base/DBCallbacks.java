package com.didi.carmate.dreambox.core.v4.base;

/**
 * author: chenjing
 * date: 2020/10/26
 */
public class DBCallbacks extends DBNode {
    private DBCallbacks(DBContext dbContext) {
        super(dbContext);
    }

    public static String getNodeTag() {
        return "callbacks";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBCallbacks createNode(DBContext dbContext) {
            return new DBCallbacks(dbContext);
        }
    }
}
