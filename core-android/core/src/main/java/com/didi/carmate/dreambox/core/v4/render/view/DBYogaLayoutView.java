package com.didi.carmate.dreambox.core.v4.render.view;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;

import com.didi.carmate.dreambox.core.v4.base.DBBorderCorner;
import com.facebook.yoga.android.YogaLayout;

/**
 * author: chenjing
 * date: 2020/5/22
 */
public class DBYogaLayoutView extends YogaLayout {
    private final DBBorderCorner mBorderCorner;

    public DBYogaLayoutView(Context context) {
        this(context, null);
    }

    public DBYogaLayoutView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public DBYogaLayoutView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        mBorderCorner = new DBBorderCorner();
    }

    public void setBorderColor(int color) {
        mBorderCorner.setBorderColor(color);
    }

    public void setBorderWidth(int borderWidth) {
        mBorderCorner.setBorderWidth(borderWidth);
    }

    public void setRadius(int radius) {
        mBorderCorner.setRadius(radius);
    }

    public void setRoundRadius(int radius, int lt, int rt, int rb, int lb) {
        mBorderCorner.setRoundRadius(radius, lt, rt, rb, lb);
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);

        mBorderCorner.dispatchDraw(canvas, getWidth(), getHeight());
    }

    @Override
    public void draw(Canvas canvas) {
        if (mBorderCorner.isDrawCorner()) {
//            android.util.Log.d("TMP_TEST", "draw corner: " + this);
            int save = canvas.save();
            mBorderCorner.draw(canvas, getWidth(), getHeight());
            super.draw(canvas);
            canvas.restoreToCount(save);
        } else {
//            android.util.Log.d("TMP_TEST", "not draw corner: " + this);
            super.draw(canvas);
        }
    }

//    @Override
//    public void requestLayout() {
//        if (!(getParent() instanceof YogaLayout) && null != getYogaNode()) {
//            getYogaNode().setHeight(LayoutParams.WRAP_CONTENT);
//        }
//        super.requestLayout();
//    }
}