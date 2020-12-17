package com.didi.carmate.dreambox.core.yoga.base;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBNode;
import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.yoga.render.IDBYoga;
import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;

import java.util.List;

/**
 * author: chenjing
 * date: 2020/11/10
 */
public abstract class DBBindView extends DBNode implements IDBYoga {
    protected DBBindView(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void bindView(DBYogaView rootView) {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBYoga) {
                ((IDBYoga) child).bindView(rootView);
            }
        }
    }
}
