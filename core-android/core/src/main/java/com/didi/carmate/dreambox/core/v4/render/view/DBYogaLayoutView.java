package com.didi.carmate.dreambox.core.v4.render.view;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;

import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.facebook.yoga.android.YogaLayout;

/**
 * author: chenjing
 * date: 2020/5/22
 */
public class DBYogaLayoutView extends YogaLayout {
    private final Path mPath;
    private final Path mBorderPath;
    private final Paint mPaint;
    private final Paint mBoarderPaint;
    private final RectF mRect;
    private final RectF mBorderRect;
    private final float[] mCorners;
    private int borderWidth;

    public DBYogaLayoutView(DBContext dbContext) {
        this(dbContext, null);
    }

    public DBYogaLayoutView(DBContext dbContext, AttributeSet attrs) {
        this(dbContext, attrs, 0);
    }

    public DBYogaLayoutView(DBContext dbContext, AttributeSet attrs, int defStyleAttr) {
        super(dbContext.getContext(), attrs, defStyleAttr);

        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mPaint.setColor(Color.TRANSPARENT);
        mPaint.setStyle(Paint.Style.FILL);
        mPath = new Path();
        mRect = new RectF();

        mBoarderPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mBoarderPaint.setColor(Color.TRANSPARENT);
        mBoarderPaint.setStyle(Paint.Style.STROKE);
        mBorderPath = new Path();
        mBorderRect = new RectF();

        mCorners = new float[]{
                0, 0,        // Top left radius in px
                0, 0,        // Top right radius in px
                0, 0,        // Bottom right radius in px
                0, 0         // Bottom left radius in px
        };
    }

    public void setBorderWidth(int borderWidth) {
        this.borderWidth = borderWidth;
        mBoarderPaint.setStrokeWidth(borderWidth);
    }

    public void setBorderColor(int color) {
        mBoarderPaint.setColor(color);
    }

    public void setRadius(int radius) {
        mCorners[0] = radius;
        mCorners[1] = radius;
        mCorners[2] = radius;
        mCorners[3] = radius;
        mCorners[4] = radius;
        mCorners[5] = radius;
        mCorners[6] = radius;
        mCorners[7] = radius;
    }

    public void setRoundRadius(int lt, int rt, int rb, int lb) {
        if (lt != 0) {
            mCorners[0] = lt;
            mCorners[1] = lt;
        }
        if (rt != 0) {
            mCorners[2] = rt;
            mCorners[3] = rt;
        }
        if (rb != 0) {
            mCorners[4] = rb;
            mCorners[5] = rb;
        }
        if (lb != 0) {
            mCorners[6] = lb;
            mCorners[7] = lb;
        }
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        mBorderPath.reset();
        mBorderRect.set(0, 0, w, h);
        mBorderPath.addRoundRect(mBorderRect, mCorners, Path.Direction.CW);

        mPath.reset();
        mRect.set(borderWidth, borderWidth, w - borderWidth, h - borderWidth);
        mPath.addRoundRect(mRect, mCorners, Path.Direction.CW);
//        mPath.addRoundRect(mRect, 4, 4, Path.Direction.CW);
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        canvas.save();

        //创建边框矩形区域
        canvas.drawPath(mBorderPath, mBoarderPaint);
        //创建真实图片矩形区域
        canvas.drawPath(mPath, mPaint);

        super.dispatchDraw(canvas);
        canvas.restore();
    }
}