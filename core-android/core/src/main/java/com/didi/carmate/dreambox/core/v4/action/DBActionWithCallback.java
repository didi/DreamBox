package com.didi.carmate.dreambox.core.v4.action;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBCallbacks;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.IDBNode;
import com.didi.carmate.dreambox.core.v4.base.DBCallback;

import java.util.ArrayList;
import java.util.List;

/**
 * author: chenjing
 * date: 2020/10/26
 */
public abstract class DBActionWithCallback extends DBAction {
    private final List<DBCallback> mCallbacks = new ArrayList<>();

    public DBActionWithCallback(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void onParserNode() {
        super.onParserNode();

        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof DBCallbacks) { // callback 集合
                List<IDBNode> callbacks = child.getChildren();
                for (IDBNode callback : callbacks) {
                    if (callback instanceof DBCallback) {
                        mCallbacks.add((DBCallback) callback);
                    }
                }
            }
        }
    }

    public List<DBCallback> getCallbacks() {
        return mCallbacks;
    }
}
