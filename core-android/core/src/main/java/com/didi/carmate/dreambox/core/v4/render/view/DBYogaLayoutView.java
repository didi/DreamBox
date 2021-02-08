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
    private final Paint mBorderPaint;
    private final RectF mRect;
    private final RectF mBorderRect;
    private final float[] mCorners;
    private int mBorderWidth;

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

        mBorderPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mBorderPaint.setColor(Color.TRANSPARENT);
        mBorderPaint.setStyle(Paint.Style.STROKE);
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
        mBorderWidth = borderWidth;
        mBorderPaint.setStrokeWidth(borderWidth);
    }

    public void setBorderColor(int color) {
        mBorderPaint.setColor(color);
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

        float padding = (float) mBorderWidth / 2; // 留一个内边距，否则部分边框绘制在控件外面，导致看不全
        mPath.reset();
        mRect.set(mBorderWidth, mBorderWidth, w - mBorderWidth, h - mBorderWidth);
        mPath.addRoundRect(mRect, mCorners, Path.Direction.CW);

        mBorderPath.reset();
        mBorderRect.set(padding, padding, w - padding, h - padding);
        mBorderPath.addRoundRect(mBorderRect, mCorners, Path.Direction.CW);
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        canvas.save();

        //创建边框矩形区域
        canvas.drawPath(mBorderPath, mBorderPaint);
        //创建真实图片矩形区域
        canvas.drawPath(mPath, mPaint);

        super.dispatchDraw(canvas);
        canvas.restore();
    }

//    @Override
//    public void requestLayout() {
//        if (!(getParent() instanceof YogaLayout) && null != getYogaNode()) {
//            getYogaNode().setHeight(LayoutParams.WRAP_CONTENT);
//        }
//        super.requestLayout();
//    }
}