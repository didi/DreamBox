package com.didi.carmate.catalog.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.didi.carmate.catalog.view.DBPageContainer;
import com.didi.dreambox.catalog.R;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class DBDisplayActivity extends AppCompatActivity implements View.OnClickListener {

    private TextView showViewBtn, showCodeBtn;
    private DBPageContainer displayView;
    private TextView displayCode;
    private String dbName;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_db_display);
        showViewBtn = findViewById(R.id.db_catalog_display);
        showCodeBtn = findViewById(R.id.db_catalog_code);
        showViewBtn.setBackgroundResource(R.drawable.db_playground_btn_bg_selected);
        showCodeBtn.setBackgroundResource(R.drawable.db_playground_btn_bg);
        showViewBtn.setOnClickListener(this);
        showCodeBtn.setOnClickListener(this);
        displayView = findViewById(R.id.db_catalog_display_view);
        displayCode = findViewById(R.id.db_catalog_display_code);
        displayCode.setVisibility(View.GONE);
        displayCode.setMovementMethod(ScrollingMovementMethod.getInstance());
        displayCode.setHorizontallyScrolling(true);
        displayCode.setFocusable(true);
        initData();
    }

    private void initData() {
        dbName = getName();
        String ext = getStringFromAssets(dbName + ".json");
        if (!TextUtils.isEmpty(ext)) {
            displayView.render(dbName, ext);
        } else {
            displayView.render(dbName);
        }
        displayCode.setText(prettyFormat(dbName));
    }

    private String getName() {
        Intent intent = this.getIntent();
        return intent.getStringExtra("name");
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.db_catalog_display) {
            showViewBtn.setBackgroundResource(R.drawable.db_playground_btn_bg_selected);
            showCodeBtn.setBackgroundResource(R.drawable.db_playground_btn_bg);
            displayView.setVisibility(View.VISIBLE);
            displayCode.setVisibility(View.GONE);
        } else if (id == R.id.db_catalog_code) {
            showCodeBtn.setBackgroundResource(R.drawable.db_playground_btn_bg_selected);
            showViewBtn.setBackgroundResource(R.drawable.db_playground_btn_bg);
            displayView.setVisibility(View.GONE);
            displayCode.setVisibility(View.VISIBLE);
        }

    }

    public String prettyFormat(String fileName) {

        String result = null;
        try {
            InputStream is = getAssets().open(new StringBuilder().
                    append(fileName).append(".xml").toString());
            int length = is.available();
            byte[] buffer = new byte[length];
            is.read(buffer);
            result = new String(buffer, "utf8");
        } catch (IOException e) {
            e.printStackTrace();
        }

        if (TextUtils.isEmpty(result)) {
            Log.e("DBDisplayActivity", "读取文件出错！！！");
            return null;
        }

        return result;
    }

    private String getStringFromAssets(String fileName) {
        StringBuilder jsonSb = new StringBuilder();
        try {
            // 字节流
            InputStream is = getAssets().open(fileName);
            InputStreamReader isr = new InputStreamReader(is, "UTF-8");
            BufferedReader bfr = new BufferedReader(isr);

            String in;
            while ((in = bfr.readLine()) != null) {
                jsonSb.append(in);
            }
            is.close();
            isr.close();
            bfr.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return jsonSb.toString();
    }

}
