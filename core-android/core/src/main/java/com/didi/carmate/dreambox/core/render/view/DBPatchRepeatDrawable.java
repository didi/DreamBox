package com.didi.carmate.dreambox.core.render.view;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;

import androidx.annotation.NonNull;

/**
 * author: chenjing
 * date: 2020/6/29
 */
public class DBPatchRepeatDrawable extends Drawable {
    private Bitmap mBitmap;
    private PatchDrawableFactory.RangeLists mRangeLists;

    private Rect mRectBitmapSrc;
    private Rect mRectStartSrc;
    private Rect mRectRepeatSrc;
    private Rect mRectEndSrc;
    private RectF mRectBitmapDst;
    private RectF mRectStartDst;
    private RectF mRectRepeatDst;
    private RectF mRectEndDst;

    private final Paint mPaint;
    private int repeatXStart;
    private int repeatXEnd;
    private int repeatRectFDstHeight;
    private int repeatXStep;
    private boolean widthZero;
    private boolean tooSmall;

    DBPatchRepeatDrawable(Bitmap bitmap, PatchDrawableFactory.RangeLists rangeLists) {
        mBitmap = bitmap;
        mRangeLists = rangeLists;
        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

        int xStart = mRangeLists.rangeListX.get(0).start;
        int xEnd = mRangeLists.rangeListX.get(0).end;
        repeatXStep = xEnd - xStart;

        // image 整体绘制
        mRectBitmapSrc = new Rect(0, 0, mBitmap.getWidth(), mBitmap.getHeight());
        mRectBitmapDst = new RectF();
        // start area
        mRectStartSrc = new Rect(0, 0, xStart, mBitmap.getHeight());
        mRectStartDst = new RectF();
        // repeat area
        mRectRepeatSrc = new Rect(xStart, 0, xEnd, mBitmap.getHeight());
        mRectRepeatDst = new RectF();
        // end area
        mRectEndSrc = new Rect(xEnd, 0, mBitmap.getWidth(), mBitmap.getHeight());
        mRectEndDst = new RectF();
    }

    @Override
    protected void onBoundsChange(Rect bounds) {
        super.onBoundsChange(bounds);

        int startWidth = mRangeLists.rangeListX.get(0).start;
        int endWidth = mBitmap.getWidth() - mRangeLists.rangeListX.get(0).end;
        int endLeft = bounds.width() - (mBitmap.getWidth() - mRangeLists.rangeListX.get(0).end);

        repeatRectFDstHeight = bounds.height();
        repeatXStart = mRangeLists.rangeListX.get(0).start;
        repeatXEnd = bounds.width() - endWidth;

        if (bounds.width() == 0) {
            widthZero = true;
        } else if (bounds.width() <= startWidth + endWidth) {
            tooSmall = true;
            mRectBitmapDst.set(0, 0, bounds.width(), bounds.height());
            mRectBitmapSrc.set(0, 0, bounds.width(), mBitmap.getHeight());
        } else {
            mRectStartDst.set(0, 0, mRangeLists.rangeListX.get(0).start, bounds.height());
            mRectEndDst.set(endLeft, 0, bounds.width(), bounds.height());
        }
    }

    @Override
    public void draw(@NonNull Canvas canvas) {
        if (!widthZero) {
            if (!tooSmall) {
                // start
                canvas.drawBitmap(mBitmap, mRectStartSrc, mRectStartDst, mPaint);
                // repeat
                int currentX = repeatXStart;
                while ((currentX + repeatXStep) <= repeatXEnd) {
                    mRectRepeatDst.set(currentX, 0, currentX + repeatXStep, repeatRectFDstHeight);
                    canvas.drawBitmap(mBitmap, mRectRepeatSrc, mRectRepeatDst, mPaint);
                    currentX += repeatXStep;
                }
                // 画剩下的部分
                if (currentX < repeatXEnd) {
                    mRectRepeatDst.set(currentX, 0, repeatXEnd, repeatRectFDstHeight);
                    canvas.drawBitmap(mBitmap, mRectRepeatSrc, mRectRepeatDst, mPaint);
                }
                // end
                canvas.drawBitmap(mBitmap, mRectEndSrc, mRectEndDst, mPaint);
            } else {
                canvas.drawBitmap(mBitmap, mRectBitmapSrc, mRectBitmapDst, mPaint);
            }
        }
    }

    @Override
    public int getOpacity() {
        return PixelFormat.TRANSLUCENT;
    }

    @Override
    public void setAlpha(int alpha) {
        mPaint.setAlpha(alpha);
    }

    @Override
    public void setColorFilter(ColorFilter cf) {
        mPaint.setColorFilter(cf);
    }
}
