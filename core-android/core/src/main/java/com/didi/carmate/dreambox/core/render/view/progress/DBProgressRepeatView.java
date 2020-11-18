package com.didi.carmate.dreambox.core.render.view.progress;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.View;

import com.didi.carmate.dreambox.core.render.view.DBPatchRepeatDrawable;
import com.didi.carmate.dreambox.core.render.view.PatchDrawableFactory;

/**
 * author: chenjing
 * date: 2020/6/28
 */
public class DBProgressRepeatView extends View {
    public DBProgressRepeatView(Context context) {
        this(context, null);
    }

    public DBProgressRepeatView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public void setBackground(Drawable background) {
        if (!(background instanceof BitmapDrawable)) {
            return;
        }

        Bitmap bitmap = ((BitmapDrawable) background).getBitmap();
        DBPatchRepeatDrawable drawable = PatchDrawableFactory.createRepeatPatchDrawable(getResources(), bitmap);
        super.setBackground(drawable);
    }
}
