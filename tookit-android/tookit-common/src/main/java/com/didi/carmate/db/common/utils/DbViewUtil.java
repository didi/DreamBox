package com.didi.carmate.db.common.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.widget.ImageView;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;


public class DbViewUtil {


    public static float density(@NonNull Context context) {
        return context.getResources().getDisplayMetrics().density;
    }

    public static int dp2px(@NonNull Context context, float dp) {
        float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dp * scale + 0.5f);
    }


    public static int px2dp(@NonNull Context context, float dp) {
        return Math.round(dp / context.getResources().getDisplayMetrics().density);
    }


    //只支持CENTER_CROP
    @Nullable
    public static Bitmap scale(Bitmap source, ImageView.ScaleType scaleType, @IntRange(from = 1) int outWidth,
                               @IntRange(from = 1) int outHeight, boolean recycleSource) {
        if (scaleType != ImageView.ScaleType.CENTER_CROP) {
            return source;
        }

        if (source != null && !source.isRecycled()) {
            Bitmap scaledBitmap = null;
            float sourceWidth = (float) source.getWidth();
            float sourceHeight = (float) source.getHeight();
            float sourceRatio = sourceWidth / sourceHeight;
            float targetRatio = outWidth / outHeight;
            float scale;
            int x = 0;
            int y = 0;

            scale = sourceRatio > targetRatio ? outHeight / sourceHeight : outWidth / sourceWidth;
            outHeight *= (float) 1 / scale;
            outWidth *= (float) 1 / scale;
            if (sourceRatio > 1f) {
                x = (int) ((sourceWidth - outWidth) / 2);
                y = 0;
            } else if (sourceRatio < 1f) {
                x = 0;
                y = (int) ((sourceHeight - outHeight) / 2);
            }

            if (scale == 1.0F) {
                return source;
            } else {
                Matrix matrix = new Matrix();
                matrix.setScale(scale, scale);
                try {
                    scaledBitmap = Bitmap.createBitmap(source, x, y, outWidth, outHeight, matrix, true);
                } catch (IllegalArgumentException ignore) {
                    ignore.printStackTrace();
                } catch (OutOfMemoryError ignore) {
                    ignore.printStackTrace();
                }
                return scaledBitmap;
            }
        }
        return null;
    }

}
