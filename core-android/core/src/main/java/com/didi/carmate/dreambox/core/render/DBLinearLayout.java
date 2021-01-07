package com.didi.carmate.dreambox.core.render;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBContainer;
import com.didi.carmate.dreambox.core.render.view.DBLinearLayoutView;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBLinearLayout extends DBContainer<ViewGroup> {
    public DBLinearLayout(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public DBLinearLayoutView onCreateView() {
        return new DBLinearLayoutView(mDBContext);
    }
}
