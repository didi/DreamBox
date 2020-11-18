package com.didi.carmate.dreambox.core.bridge;

import androidx.annotation.Nullable;

import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/7/16
 */
public interface IDBEventReceiver {
    /**
     * 处理DreamBox发送过来的事件
     *
     * @param msg      传递的数据
     * @param callback 回调对象
     */
    void onEvent(JsonObject msg, @Nullable Callback callback);

    interface Callback {
        void onCallback(String msgTo);
    }
}
