package com.airk.dreamhouse;

import android.app.Application;

import com.didi.carmate.dreambox.shell.v4.DreamBox;

public class DemoApplication extends Application {

    public static final String ACCESS_KEY = "dmb-demo";

    @Override
    public void onCreate() {
        super.onCreate();
        DreamBox.getInstance().register(ACCESS_KEY, this, null);
    }
}
