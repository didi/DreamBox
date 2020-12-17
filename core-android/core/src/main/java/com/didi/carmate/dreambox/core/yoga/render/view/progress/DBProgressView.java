package com.didi.carmate.dreambox.core.yoga.render.view.progress;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Paint;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.IntRange;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.yoga.render.view.PatchDrawableFactory;

/**
 * author: chenjing
 * date: 2020/5/23
 */
public class DBProgressView extends FrameLayout {
    private int progress;
    private View foregroundView;
    private String patchType;
    private final int radius;
    private int fgColor;
    private final boolean isColorProgress;

    public DBProgressView(Context context, String patchType, int radius) {
        super(context);
        this.patchType = patchType;
        this.radius = radius;
        this.isColorProgress = false;
        init();
    }

    public DBProgressView(Context context, int radius, int fgColor) {
        super(context);
        this.radius = radius;
        this.fgColor = fgColor;
        this.isColorProgress = true;
        init();
    }

    private void init() {
        if (isColorProgress) {
            foregroundView = new View(getContext());
        } else {
            if (patchType.equals(DBConstants.STYLE_PATCH_TYPE_REPEAT)) {
                foregroundView = new DBProgressRepeatView(getContext());
            } else {
                foregroundView = new DBProgressStretchView(getContext());
            }
        }
        LayoutParams lp = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT);
        addView(foregroundView, lp);
    }

    @Override
    public void setBackground(Drawable background) {
        if (!(background instanceof BitmapDrawable) && !(background instanceof ShapeDrawable)) {
            return;
        }

        Drawable backgroundDrawable;
        if (background instanceof BitmapDrawable) {
            Bitmap bitmap = ((BitmapDrawable) background).getBitmap();
            if (patchType.equals(DBConstants.STYLE_PATCH_TYPE_REPEAT)) {
                backgroundDrawable = PatchDrawableFactory.createRepeatPatchDrawable(getResources(), bitmap);
            } else {
                backgroundDrawable = PatchDrawableFactory.createNinePatchDrawable(getResources(), bitmap);
            }
        } else {
            backgroundDrawable = background;
        }
        super.setBackground(backgroundDrawable);
    }

    public void setProgress(@IntRange(from = 0, to = 100) int progress) {
        int value;
        if (progress > 100) {
            value = 100;
        } else if (progress < 0) {
            value = 0;
        } else {
            value = progress;
        }
        this.progress = value;
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        ViewGroup.LayoutParams lp = foregroundView.getLayoutParams();
        if (progress > 0) {
            int bgWidth = w * progress;
            lp.width = Math.max(bgWidth / 100, radius != 0 ? radius : 10); // 影响绘制效果，宽度最少为radius
        } else {
            lp.width = 0;
        }
        lp.height = h;
        foregroundView.setLayoutParams(lp);

        if (isColorProgress) {
            setForegroundDrawable(lp.width <= radius * 2);
        }
    }

    public View getForegroundView() {
        return foregroundView;
    }

    private void setForegroundDrawable(boolean isTooSmall) {
        float[] fgOuterRadius;
        if (isTooSmall) {
            fgOuterRadius = new float[]{radius, radius, 0, 0, 0, 0, radius, radius};
        } else {
            fgOuterRadius = new float[]{radius, radius, radius, radius, radius, radius, radius, radius};
        }
        // 前景drawable
        RoundRectShape fgShape = new RoundRectShape(fgOuterRadius, null, null);
        ShapeDrawable fgDrawable = new ShapeDrawable(fgShape);
        fgDrawable.getPaint().setColor(fgColor);
        fgDrawable.getPaint().setAntiAlias(true);
        fgDrawable.getPaint().setStyle(Paint.Style.FILL_AND_STROKE);//描边
        foregroundView.setBackground(fgDrawable);
    }
}
