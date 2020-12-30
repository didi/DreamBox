package com.didi.carmate.playground.view;

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


public class PlayGroundView extends FrameLayout {

    private DreamBoxView dreamBoxView;

    public PlayGroundView(@NonNull Context context) {
        this(context, null);
    }

    public PlayGroundView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, -1);
    }

    public PlayGroundView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        dreamBoxView = new DreamBoxView(getContext());
        dreamBoxView.render(ACCESS_KEY, "playground", null);
        if (null == dreamBoxView.getLayoutParams()) {
            addView(dreamBoxView, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        } else {
            addView(dreamBoxView);
        }
    }

    @SuppressLint("RestrictedApi")
    public boolean render(@NonNull final String template) {

        if (TextUtils.isEmpty(template)) {
            return false;
        }
        if (dreamBoxView == null) {
            dreamBoxView = new DreamBoxView(getContext());
            dreamBoxView.render(ACCESS_KEY, "playground", null);
            if (null == dreamBoxView.getLayoutParams()) {
                addView(dreamBoxView, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            } else {
                addView(dreamBoxView);
            }
        }
        dreamBoxView.reloadWithTemplate(template);
        return true;
    }

    @SuppressLint("RestrictedApi")
    public boolean setData(@NonNull final String ext) {
        if (TextUtils.isEmpty(ext) || dreamBoxView == null) {
            return false;
        }
        if (dreamBoxView == null) {
            dreamBoxView = new DreamBoxView(getContext());
            dreamBoxView.render(ACCESS_KEY, "playground", null);
            if (null == dreamBoxView.getLayoutParams()) {
                addView(dreamBoxView, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            } else {
                addView(dreamBoxView);
            }
        }
        dreamBoxView.setExtJsonStr(ext);
        return true;
    }
}
