package com.didi.carmate.dreambox.wrapper.v4;

import androidx.annotation.NonNull;

import android.view.View;
import android.widget.ImageView;

public interface ImageLoader {

    ImageLoader empty = new ImageLoader() {
        @Override
        public void load(@NonNull String url, @NonNull ImageView imageView) {

        }

        @Override
        public void load(@NonNull String url, @NonNull View view) {

        }
    };

    void load(@NonNull String url, @NonNull ImageView imageView);

    void load(@NonNull String url, @NonNull View view);
}
