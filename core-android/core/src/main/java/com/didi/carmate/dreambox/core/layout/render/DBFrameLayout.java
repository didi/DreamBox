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
        DBFrameLayoutView layoutView = new DBFrameLayoutView(mDBContext);
        ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        layoutView.setLayoutParams(lp);
        return layoutView;
    }
}
