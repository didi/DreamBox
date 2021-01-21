package com.didi.dreambox.tools.demo;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.didi.carmate.db.common.utils.DbApplication;
import com.didi.carmate.dreambox.shell.v4.DreamBoxView;


public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_content);

        DreamBoxView v = findViewById(R.id.db_view);
        v.render(DbApplication.ACCESS_KEY, "debug-view", null, null, getLifecycle());
    }
}
