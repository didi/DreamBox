package com.didi.carmate.dreambox.wrapper;

import androidx.annotation.NonNull;

public interface Log {

    Log empty = new Log() {
        @Override
        public void v(@NonNull String msg) {

        }

        @Override
        public void d(@NonNull String msg) {

        }

        @Override
        public void i(@NonNull String msg) {

        }

        @Override
        public void w(@NonNull String msg) {

        }

        @Override
        public void e(@NonNull String msg) {

        }
    };

    void v(@NonNull String msg);

    void d(@NonNull String msg);

    void i(@NonNull String msg);

    void w(@NonNull String msg);

    void e(@NonNull String msg);
}
