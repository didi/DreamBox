package com.didi.carmate.dreambox.core.v4.render;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatTextView;

import com.didi.carmate.dreambox.core.v4.base.DBBorderCorner;

/**
 * Author: chenjing
 * Date: 2021/2/16 11:45 AM
 */
public class DBTextView extends AppCompatTextView {
    private final DBBorderCorner mBorderCorner;

    public DBTextView(Context context) {
        this(context, null);
    }

    public DBTextView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);

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
            int save = canvas.save();
            mBorderCorner.draw(canvas, getWidth(), getHeight());
            super.draw(canvas);
            canvas.restoreToCount(save);
        } else {
            super.draw(canvas);
        }
    }
}
