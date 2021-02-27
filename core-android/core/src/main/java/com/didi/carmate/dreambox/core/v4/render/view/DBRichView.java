package com.didi.carmate.dreambox.core.v4.render.view;

import android.content.Context;
import android.graphics.Canvas;
import android.view.View;

import com.didi.carmate.dreambox.core.v4.base.DBBorderCorner;

/**
 * author: chenjing
 * date: 2020/6/23
 * <p>
 * 支持圆形，圆角矩形及其他图形
 * 支持边框/背景/pressed
 */
public class DBRichView extends View {
    private final DBBorderCorner mBorderCorner;

    public DBRichView(Context context, DBBorderCorner borderCorner) {
        super(context);

        mBorderCorner = borderCorner;
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

    public void clipOutline(DBBorderCorner.DBViewOutline clipOutline) {
        mBorderCorner.clipOutline(this, clipOutline);
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);

        mBorderCorner.dispatchDraw(canvas, getWidth(), getHeight());
    }

    @Override
    public void draw(Canvas canvas) {
        if (mBorderCorner.isDrawEachCorner()) {
            int save = canvas.save();
            mBorderCorner.draw(canvas, getWidth(), getHeight());
            super.draw(canvas);
            canvas.restoreToCount(save);
        } else {
            super.draw(canvas);
        }
    }
}