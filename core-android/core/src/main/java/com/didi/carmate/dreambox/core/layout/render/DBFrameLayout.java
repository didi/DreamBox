package com.didi.carmate.dreambox.core.layout.render;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.layout.base.DBContainer;
import com.didi.carmate.dreambox.core.layout.render.view.DBFrameLayoutView;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBFrameLayout extends DBContainer<ViewGroup> {
    public DBFrameLayout(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public DBFrameLayoutView onCreateView() {
        return new DBFrameLayoutView(mDBContext);
    }
}
