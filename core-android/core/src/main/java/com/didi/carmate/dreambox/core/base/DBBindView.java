package com.didi.carmate.dreambox.core.base;

import com.didi.carmate.dreambox.core.render.IDBRender;
import com.didi.carmate.dreambox.core.render.view.DBRootView;

import java.util.List;

/**
 * author: chenjing
 * date: 2020/11/10
 */
public abstract class DBBindView extends DBNode implements IDBRender {
    protected DBBindView(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void bindView(DBRootView rootView) {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBRender) {
                ((IDBRender) child).bindView(rootView);
            }
        }
    }
}
