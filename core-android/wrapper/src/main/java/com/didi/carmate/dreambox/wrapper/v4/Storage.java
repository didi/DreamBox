package com.didi.carmate.dreambox.wrapper.v4;

import androidx.annotation.NonNull;

public interface Storage {

    Storage empty = new Storage() {
        @Override
        public void put(@NonNull String key, @NonNull String value) {

        }

        @Override
        public String get(@NonNull String key, @NonNull String defaultValue) {
            return null;
        }
    };

    void put(@NonNull String key, @NonNull String value);

    String get(@NonNull String key, @NonNull String defaultValue);
}
