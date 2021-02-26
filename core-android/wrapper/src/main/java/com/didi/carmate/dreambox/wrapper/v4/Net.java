package com.didi.carmate.dreambox.wrapper.v4;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public interface Net {

    Net empty = new Net() {
        @Override
        public void get(@NonNull String url, @Nullable Callback cb) {

        }
    };

    interface Callback {
        void onSuccess(@Nullable String json);

        void onError(int httpCode, @Nullable Exception error);
    }

    void get(@NonNull String url, @Nullable Callback cb);
}
