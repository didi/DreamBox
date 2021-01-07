package com.didi.carmate.dreambox.core.render.view;

import android.util.AttributeSet;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.facebook.yoga.android.YogaLayout;

/**
 * author: chenjing
 * date: 2020/5/22
 */
public class DBLinearLayoutView extends YogaLayout {
    private final DBContext mDBContext;

    public DBLinearLayoutView(DBContext dbContext) {
        super(dbContext.getContext(), null);
        mDBContext = dbContext;
    }

    public DBLinearLayoutView(DBContext dbContext, AttributeSet attrs) {
        super(dbContext.getContext(), attrs);
        mDBContext = dbContext;
    }

    public DBLinearLayoutView(DBContext dbContext, AttributeSet attrs, int defStyleAttr) {
        super(dbContext.getContext(), attrs, defStyleAttr);
        mDBContext = dbContext;
    }
}
