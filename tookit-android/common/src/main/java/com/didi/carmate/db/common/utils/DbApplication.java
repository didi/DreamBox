package com.didi.carmate.db.common.utils;

import android.app.Application;

import com.didi.carmate.dreambox.shell.DreamBox;


public class DbApplication extends Application {

    public static final String ACCESS_KEY = "dm-demo";

    @Override
    public void onCreate() {
        super.onCreate();
        DreamBox.getInstance().register(ACCESS_KEY, this, null);
    }
}
