package com.didi.carmate.dreambox.core.yoga.render.view;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.widget.ProgressBar;

/**
 * author: chenjing
 * date: 2020/5/23
 */
public class DBCircleLoading extends ProgressBar {
    public DBCircleLoading(Context context) {
        super(context);
    }

    public DBCircleLoading(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public DBCircleLoading(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setDrawable(int drawableId) {
        Drawable drawable = getContext().getResources().getDrawable(drawableId);
        // drawable.setBounds(1, 1, 16, 16);
        setIndeterminateDrawable(drawable);
    }
}
