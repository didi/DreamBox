package com.didi.carmate.catalog.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.didi.carmate.dreambox.shell.DreamBoxView;

import static com.didi.carmate.db.common.utils.DbApplication.ACCESS_KEY;


public class DBPageContainer extends FrameLayout {

    private DreamBoxView dreamBoxView;

    public DBPageContainer(@NonNull Context context) {
        this(context, null);
    }

    public DBPageContainer(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, -1);
    }

    public DBPageContainer(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @SuppressLint("RestrictedApi")
    public boolean render(@NonNull final String template) {

        if (TextUtils.isEmpty(template)) {
            return false;
        }
        if (dreamBoxView == null) {
            dreamBoxView = new DreamBoxView(getContext());
            addView(dreamBoxView, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT));
        }
        dreamBoxView.render(ACCESS_KEY, template, null);
        return true;
    }

    @SuppressLint("RestrictedApi")
    public boolean render(@NonNull final String template, String extJsonStr) {

        if (TextUtils.isEmpty(template) || TextUtils.isEmpty(extJsonStr)) {
            return false;
        }
        if (dreamBoxView == null) {
            dreamBoxView = new DreamBoxView(getContext());
            addView(dreamBoxView, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT));
        }
        dreamBoxView.render(ACCESS_KEY, template, extJsonStr, null);
        return true;
    }
}
