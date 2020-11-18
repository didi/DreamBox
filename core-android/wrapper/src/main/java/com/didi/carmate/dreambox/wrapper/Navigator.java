package com.didi.carmate.dreambox.wrapper;

import android.content.Context;

import androidx.annotation.NonNull;

public interface Navigator {

    Navigator empty = new Navigator() {
        @Override
        public void navigator(@NonNull Context context, @NonNull String url) {

        }
    };

    void navigator(@NonNull Context context, @NonNull String url);

}
