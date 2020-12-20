package com.didi.carmate.dreambox.core.layout.base;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBNode;
import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.layout.render.IDBRender;

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
    public void bindView(ViewGroup container) {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBRender) {
                ((IDBRender) child).bindView(container);
            }
        }
    }

    @Override
    public void bindView(ViewGroup container, boolean containerHasCreated) {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBRender) {
                ((IDBRender) child).bindView(container, containerHasCreated);
            }
        }
    }
}
