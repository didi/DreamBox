package com.didi.carmate.dreambox.core.v4.render;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Shader;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;

import androidx.appcompat.widget.AppCompatImageView;

public class RoundRectImageView extends AppCompatImageView {
    private final Paint paint;
    private final Paint boarderPaint;
    private final Rect rectSrc = new Rect();
    private final Rect rectDest = new Rect();
    private final float[] mCorners;
    private int border;

    public RoundRectImageView(Context context) {
        this(context, null);
    }

    public RoundRectImageView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public RoundRectImageView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        paint = new Paint();
        boarderPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        boarderPaint.setColor(Color.GREEN);
        mCorners = new float[]{
                0, 0,        // Top left radius in px
                0, 0,        // Top right radius in px
                0, 0,        // Bottom right radius in px
                0, 0         // Bottom left radius in px
        };
    }

    public void setBorderWidth(int border) {
        this.border = border;
        boarderPaint.setStrokeWidth(border);
    }

    public void setBorderColor(int color) {
        boarderPaint.setColor(color);
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

    /**
     * 绘制圆角矩形图片
     */
    @Override
    protected void onDraw(Canvas canvas) {
        Drawable drawable = getDrawable();
        if (null != drawable) {
            Bitmap bitmap = getBitmapFromDrawable(drawable);
            Bitmap b = getRoundBitmapByShader(bitmap, getWidth(), getHeight());
            rectSrc.set(0, 0, b.getWidth(), b.getHeight());
            rectDest.set(0, 0, getWidth(), getHeight());
            paint.reset();
            canvas.drawBitmap(b, rectSrc, rectDest, paint);
        } else {
            super.onDraw(canvas);
        }
    }

    /**
     * 把资源图片转换成Bitmap
     */
    private Bitmap getBitmapFromDrawable(Drawable drawable) {
        int width = drawable.getIntrinsicWidth();
        int height = drawable.getIntrinsicHeight();
        Bitmap bitmap = Bitmap.createBitmap(width, height, drawable
                .getOpacity() != PixelFormat.OPAQUE ? Bitmap.Config.ARGB_8888
                : Bitmap.Config.RGB_565);
        Canvas canvas = new Canvas(bitmap);
        drawable.draw(canvas);
        return bitmap;
    }

    private Bitmap getRoundBitmapByShader(Bitmap bitmap, int outWidth, int outHeight) {
        if (bitmap == null) {
            return null;
        }
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        float widthScale = outWidth * 1f / width;
        float heightScale = outHeight * 1f / height;

        Matrix matrix = new Matrix();
        matrix.setScale(widthScale, heightScale);
        //创建输出的bitmap
        Bitmap desBitmap = Bitmap.createBitmap(outWidth, outHeight, Bitmap.Config.ARGB_8888);
        //创建canvas并传入desBitmap，这样绘制的内容都会在desBitmap上
        Canvas canvas = new Canvas(desBitmap);
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        //创建着色器
        BitmapShader bitmapShader = new BitmapShader(bitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP);
        //给着色器配置matrix
        bitmapShader.setLocalMatrix(matrix);
        paint.setShader(bitmapShader);
        //创建边框矩形区域
        Path borderPath = new Path();
        borderPath.addRoundRect(new RectF(0, 0, outWidth, outHeight), mCorners, Path.Direction.CW);
        canvas.drawPath(borderPath, boarderPaint);
        //创建真实图片矩形区域
        Path imagePath = new Path();
        imagePath.addRoundRect(new RectF(border, border, outWidth - border, outHeight - border), mCorners, Path.Direction.CW);
        canvas.drawPath(imagePath, paint);
        return desBitmap;
    }
}
