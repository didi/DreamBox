package com.didi.carmate.dreambox.core.v4.render.view;

import android.util.AttributeSet;
import android.widget.FrameLayout;

import com.didi.carmate.dreambox.core.v4.base.DBContext;

/**
 * author: chenjing
 * date: 2020/5/22
 */
public class DBFrameLayoutView extends FrameLayout {
    private final DBContext mDBContext;

    public DBFrameLayoutView(DBContext dbContext) {
        super(dbContext.getContext(), null);
        mDBContext = dbContext;
    }

    public DBFrameLayoutView(DBContext dbContext, AttributeSet attrs) {
        super(dbContext.getContext(), attrs);
        mDBContext = dbContext;
    }

    public DBFrameLayoutView(DBContext dbContext, AttributeSet attrs, int defStyleAttr) {
        super(dbContext.getContext(), attrs, defStyleAttr);
        mDBContext = dbContext;
    }
}
