package com.didi.carmate.dreambox.wrapper;

import android.content.Context;

import androidx.annotation.NonNull;

public interface Toast {

    Toast empty = new Toast() {
        @Override
        public void show(@NonNull Context context, @NonNull String msg, boolean durationLong) {

        }
    };

    void show(@NonNull Context context, @NonNull String msg, boolean durationLong);

}
