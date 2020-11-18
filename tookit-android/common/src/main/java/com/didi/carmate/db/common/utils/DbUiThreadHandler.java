package com.didi.carmate.db.common.utils;

import android.os.Handler;
import android.os.Looper;

public class DbUiThreadHandler {
    private static Handler sUiHandler = new Handler(Looper.getMainLooper());

    public static boolean post(Runnable r) {
        if (sUiHandler == null)
            return false;
        return sUiHandler.post(r);
    }

    public static boolean postDelayed(Runnable r, long delayMillis) {
        if (sUiHandler == null)
            return false;

        return sUiHandler.postDelayed(r, delayMillis);
    }

    public static Handler getUiHandler() {
        return sUiHandler;
    }

    public static boolean postOnceDelayed(Runnable r, long delayMillis) {
        if (sUiHandler == null)
            return false;
        sUiHandler.removeCallbacks(r);
        return sUiHandler.postDelayed(r, delayMillis);
    }

    public static void removeCallbacks(Runnable runnable) {
        if (sUiHandler == null)
            return;
        sUiHandler.removeCallbacks(runnable);
    }
}
