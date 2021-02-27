package com.didi.carmate.dreambox.core.v4.base;

import com.didi.carmate.dreambox.core.v4.action.DBActionAliasItem;
import com.didi.carmate.dreambox.core.v4.action.DBActions;
import com.didi.carmate.dreambox.core.v4.action.DBInvoke;

import java.util.ArrayList;
import java.util.List;

/**
 * author: chenjing
 * date: 2020/5/9
 */
public class DBCallback extends DBNode implements IDBCallback {
    private final List<DBAction> mActionNodes = new ArrayList<>();

    public DBCallback(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void onParserNode() {
        super.onParserNode();

        List<IDBNode> children = getChildren();
        if (children.size() > 0) {
            DBActions actions = (DBActions) children.get(0);
            children = actions.getChildren();
            for (IDBNode child : children) {
                if (child instanceof DBAction) {
                    mActionNodes.add((DBAction) child);
                }
            }
        }
    }

    @Override
    protected void onParserNodeFinished() {
        super.onParserNodeFinished();

        // 在DBLView的onParserNode里解析完DBActionAlias节点后，才能获取到alias相关内容
//        List<IDBNode> children = getChildren();
//        if (children.size() > 0) {
//            DBActions actions = (DBActions) children.get(0);
//            children = actions.getChildren();
//            for (IDBNode child : children) {
//                if (child instanceof DBInvoke) { // 获取invoke action
//                    DBActionAliasItem aliasItem = ((DBInvoke) child).getAliasItem();
//                    List<DBAction> actionNodes = aliasItem.getActionNodes();
//                    mActionNodes.addAll(actionNodes);
//                }
//            }
//        }
    }

    @Override
    public List<DBAction> getActionNodes() {
        return mActionNodes;
    }
}
