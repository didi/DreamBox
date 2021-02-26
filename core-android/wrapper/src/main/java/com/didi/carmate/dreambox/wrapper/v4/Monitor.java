package com.didi.carmate.dreambox.wrapper.v4;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

public interface Monitor {

    Monitor empty = new Monitor() {

        @Override
        public void report(@NonNull String type, @Nullable Map<String, String> params) {

        }

    };

    /**
     * 用于上报内部的关键信息，可用于数据监控,(主要用于运行时异常，参数不合法之类问题)
     */
    void report(@NonNull String type, @Nullable Map<String, String> params);

}
