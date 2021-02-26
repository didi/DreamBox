package com.didi.carmate.dreambox.core.v4.action;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBNode;
import com.didi.carmate.dreambox.core.v4.base.IDBNode;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBActionAlias extends DBNode {
    private final DBActionAliasItem mActionAliasItem; // 单个
    private final List<DBActionAliasItem> mActionAliasItems = new ArrayList<>(); // 碰撞为多个

    private DBActionAlias(DBContext dbContext) {
        super(dbContext);

        mActionAliasItem = new DBActionAliasItem(dbContext);
    }

    @Override
    protected void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        mActionAliasItem.setId(attrs.get("id"));
        mActionAliasItem.setAttrs(attrs);
    }

    @Override
    public void onParserNode() {
        super.onParserNode();

        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof DBActionAliasItem) {
                mActionAliasItems.add((DBActionAliasItem) child);
            } else if (child instanceof DBActions) {
                DBActions actions = (DBActions) child;
                children = actions.getChildren();
                for (IDBNode item : children) {
                    if (item instanceof DBAction) {
                        mActionAliasItem.putAction((DBAction) item);
                    }
                }
                mActionAliasItems.add(mActionAliasItem);
            }
        }
    }

    public List<DBActionAliasItem> getActionAliasItems() {
        return mActionAliasItems;
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBActionAlias createNode(DBContext dbContext) {
            return new DBActionAlias(dbContext);
        }
    }

    public static String getNodeTag() {
        return "actionAlias";
    }
}
