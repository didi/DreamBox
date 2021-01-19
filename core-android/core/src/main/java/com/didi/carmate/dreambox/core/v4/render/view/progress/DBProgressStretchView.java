package com.didi.carmate.dreambox.core.v4.render.view.progress;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.NinePatchDrawable;
import android.util.AttributeSet;
import android.view.View;

import com.didi.carmate.dreambox.core.v4.render.view.PatchDrawableFactory;

/**
 * author: chenjing
 * date: 2020/6/28
 */
public class DBProgressStretchView extends View {
    private int newWidth;

    public DBProgressStretchView(Context context) {
        this(context, null);
    }

    public DBProgressStretchView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        newWidth = w;
    }

    @Override
    public void setBackground(Drawable background) {
        if (!(background instanceof BitmapDrawable)) {
            return;
        }

        Bitmap bitmapOrigin = ((BitmapDrawable) background).getBitmap();
        PatchDrawableFactory.RangeLists rangeLists = PatchDrawableFactory.getPatchRange(bitmapOrigin);

        int startWidth = rangeLists.rangeListX.get(0).start;
        int endWidth = bitmapOrigin.getWidth() - rangeLists.rangeListX.get(0).end;
        if (newWidth <= startWidth + endWidth) { // fg View过小(进度过小)，需要特殊处理
            Bitmap bitmapTrim = PatchDrawableFactory.trimBitmap(bitmapOrigin);
            Bitmap bitmap = Bitmap.createBitmap(bitmapTrim, 0, 0, newWidth, bitmapTrim.getHeight());
            super.setBackground(new BitmapDrawable(getResources(), bitmap));
        } else {
            NinePatchDrawable drawable = PatchDrawableFactory.createNinePatchDrawable(getResources(), bitmapOrigin);
            super.setBackground(drawable);
        }
    }
}
