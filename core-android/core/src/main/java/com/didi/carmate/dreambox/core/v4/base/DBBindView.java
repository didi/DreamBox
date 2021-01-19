package com.didi.carmate.dreambox.core.v4.base;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.v4.render.IDBRender;

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
    public void bindView(NODE_TYPE nodeType) {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBRender) {
                ((IDBRender) child).bindView(nodeType);
            }
        }
    }

    @Override
    public void bindView(ViewGroup container, NODE_TYPE nodeType) {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBRender) {
                ((IDBRender) child).bindView(container, nodeType);
            }
        }
    }

    @Override
    public void bindView(ViewGroup container, NODE_TYPE nodeType, boolean bindAttrOnly){
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBRender) {
                ((IDBRender) child).bindView(container, nodeType, bindAttrOnly);
            }
        }
    }
}
