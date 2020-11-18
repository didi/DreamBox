package com.didi.carmate.dreambox.wrapper;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public interface Dialog {

    Dialog empty = new Dialog() {
        @Override
        public void show(@NonNull Context context, @Nullable String title, @Nullable String msg, @Nullable String positiveBtn, @Nullable String negativeBtn, @Nullable OnClickListener posListener, @Nullable OnClickListener negListener) {

        }
    };

    interface OnClickListener {
        void onClick();
    }

    void show(@NonNull Context context, @Nullable String title, @Nullable String msg,
              @Nullable String positiveBtn, @Nullable String negativeBtn,
              @Nullable OnClickListener posListener,
              @Nullable OnClickListener negListener);

}
