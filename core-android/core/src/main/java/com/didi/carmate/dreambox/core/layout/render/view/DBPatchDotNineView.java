package com.didi.carmate.dreambox.core.layout.render.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.NinePatchDrawable;
import android.util.AttributeSet;

import androidx.appcompat.widget.AppCompatTextView;

/**
 * author: chenjing
 * date: 2020/6/28
 */
public class DBPatchDotNineView extends AppCompatTextView {
    public DBPatchDotNineView(Context context) {
        this(context, null);
    }

    public DBPatchDotNineView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public void setBackground(Drawable drawable) {
        if (!(drawable instanceof BitmapDrawable)) {
            return;
        }

        Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
        NinePatchDrawable patchDrawable = PatchDrawableFactory.createNinePatchDrawable(getResources(), bitmap);
        super.setBackground(patchDrawable);
    }
}
