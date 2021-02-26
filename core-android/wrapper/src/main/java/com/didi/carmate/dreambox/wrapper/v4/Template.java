package com.didi.carmate.dreambox.wrapper.v4;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.WorkerThread;

public interface Template {

    Template empty = new Template() {
        @Override
        public void loadTemplate(@NonNull String templateId, @NonNull Callback callback) {
            callback.onLoadTemplate(null);
        }
    };

    interface Callback {
        /**
         * @param template 返回模板数据，如果为空，会从本地加载
         */
        @WorkerThread
        void onLoadTemplate(@Nullable String template);
    }

    /**
     * 加载模板数据
     *
     * @param templateId 模板id
     */
    @WorkerThread
    void loadTemplate(@NonNull String templateId, @NonNull Callback callback);

}
