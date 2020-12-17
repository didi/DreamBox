package com.didi.carmate.dreambox.core.yoga.render.view;

import android.util.AttributeSet;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.yoga.render.IDBYoga;
import com.facebook.yoga.android.YogaLayout;

/**
 * author: chenjing
 * date: 2020/5/22
 */
public class DBYogaView extends YogaLayout {
    private final DBContext mDBContext;

    public DBYogaView(DBContext dbContext) {
        super(dbContext.getContext(), null);
        mDBContext = dbContext;
    }

    public DBYogaView(DBContext dbContext, AttributeSet attrs) {
        super(dbContext.getContext(), attrs);
        mDBContext = dbContext;
    }

    public DBYogaView(DBContext dbContext, AttributeSet attrs, int defStyleAttr) {
        super(dbContext.getContext(), attrs, defStyleAttr);
        mDBContext = dbContext;
    }

    public void onRenderFinish(IDBYoga dbYoga) {
    }
}
