package com.didi.carmate.dreambox.core.v4.base;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;

/**
 * Author: chenjing
 * Date: 2021/2/16 11:03 AM
 */
public class DBBorderCorner {
    // border
    private Paint mBorderPaint;
    private Path mBorderPath;
    private RectF mBorderRectF;
    private int mBorderWidth;
    private int mBorderWidthOffset;
    // clip
    private Path mClipPath;
    private RectF mClipRectF;

    private float[] mCorners;
    private float[] mClipCorners; // 圆角多加2个像素clip掉，否则如果有边框的话，边框外边能隐约看到一些内容
    private float mCornerX, mCornerY;
    private boolean mIsDrawCorner;
    private boolean mIsDrawEachCorner;

    public DBBorderCorner() {
        init();
    }

    private void init() {
        mBorderPaint = new Paint();
        mBorderPaint.setAntiAlias(true);
        mBorderPaint.setStyle(Paint.Style.STROKE);
        mBorderPath = new Path();
        mBorderRectF = new RectF();

        mClipPath = new Path();
        mClipRectF = new RectF();

        mClipCorners = mCorners = new float[]{
                0, 0,        // Top left radius in px
                0, 0,        // Top right radius in px
                0, 0,        // Bottom right radius in px
                0, 0         // Bottom left radius in px
        };
        mCornerX = mCornerY = 0;
    }

    public void setBorderColor(int color) {
        mBorderPaint.setColor(color);
    }

    public void setBorderWidth(int borderWidth) {
        mBorderPaint.setStrokeWidth(borderWidth);
        mBorderWidth = borderWidth;
        mBorderWidthOffset = mBorderWidth / 2;
    }

    public void setRadius(int radius) {
        if (radius > 0) {
            mCornerX = radius;
            mCornerY = radius;
            mIsDrawCorner = true;
        }
    }

    public void setRoundRadius(int radius, int lt, int rt, int rb, int lb) {
        if (lt != 0) {
            mCorners[0] = lt;
            mCorners[1] = lt;
            mClipCorners[0] = lt + 2;
            mClipCorners[1] = lt + 2;
            mIsDrawCorner = true;
            mIsDrawEachCorner = true;
        } else {
            mCorners[0] = radius;
            mCorners[1] = radius;
        }
        if (rt != 0) {
            mCorners[2] = rt;
            mCorners[3] = rt;
            mClipCorners[2] = rt + 2;
            mClipCorners[3] = rt + 2;
            mIsDrawCorner = true;
            mIsDrawEachCorner = true;
        } else {
            mCorners[2] = radius;
            mCorners[3] = radius;
        }
        if (rb != 0) {
            mCorners[4] = rb;
            mCorners[5] = rb;
            mClipCorners[4] = rb + 2;
            mClipCorners[5] = rb + 2;
            mIsDrawCorner = true;
            mIsDrawEachCorner = true;
        } else {
            mCorners[4] = radius;
            mCorners[5] = radius;
        }
        if (lb != 0) {
            mCorners[6] = lb;
            mCorners[7] = lb;
            mClipCorners[6] = lb + 2;
            mClipCorners[7] = lb + 2;
            mIsDrawCorner = true;
            mIsDrawEachCorner = true;
        } else {
            mCorners[6] = radius;
            mCorners[7] = radius;
        }
    }

    public void dispatchDraw(Canvas canvas, int width, int height) {
        if (mBorderWidth > 0) {
//            android.util.Log.d("TMP_TEST", "draw border");
            mBorderRectF.set(mBorderWidthOffset, mBorderWidthOffset, width - mBorderWidthOffset, height - mBorderWidthOffset);
            if (mIsDrawEachCorner) {
//                android.util.Log.d("TMP_TEST", "draw each border");
                mBorderPath.addRoundRect(mBorderRectF, mCorners, Path.Direction.CW);
            } else {
//                android.util.Log.d("TMP_TEST", "draw same border");
                mBorderPath.addRoundRect(mBorderRectF, mCornerX, mCornerY, Path.Direction.CW);
            }
            canvas.drawPath(mBorderPath, mBorderPaint);
        }
//        else {
//            android.util.Log.d("TMP_TEST", "not draw border");
//        }
    }

    public boolean isDrawCorner() {
        return mIsDrawCorner;
    }

    public void draw(Canvas canvas, int width, int height) {
        mClipRectF.set(0, 0, width, height);
        if (mIsDrawEachCorner) {
//            android.util.Log.d("TMP_TEST", "draw each corner");
            if (mBorderWidth > 0) {
                mClipPath.addRoundRect(mClipRectF, mClipCorners, Path.Direction.CW);
            } else {
                mClipPath.addRoundRect(mClipRectF, mCorners, Path.Direction.CW);
            }
        } else {
//            android.util.Log.d("TMP_TEST", "draw same corner");
            if (mBorderWidth > 0) {
                mClipPath.addRoundRect(mClipRectF, mCornerX + 2, mCornerY + 2, Path.Direction.CW);
            } else {
                mClipPath.addRoundRect(mClipRectF, mCornerX, mCornerY, Path.Direction.CW);
            }
        }
        canvas.clipPath(mClipPath);
    }
}
