package com.didi.carmate.dreambox.wrapper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

public interface Trace {

    Trace empty = new Trace() {
        @Override
        public void t(@NonNull String key, Map<String, String> attrs) {

        }
    };

    void t(@NonNull String key,@Nullable Map<String, String> attrs);
}
