package com.airk.dreamhouse;

import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.airk.dreamhouse.demo.R;
import com.didi.carmate.dreambox.shell.v4.DreamBoxView;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import static com.airk.dreamhouse.DemoApplication.ACCESS_KEY;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        final ViewGroup rootContainer = findViewById(R.id.container);
        rootContainer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                DreamBoxView dreamBoxView = findViewById(R.id.dream_box);
                dreamBoxView.render(ACCESS_KEY, "helloworld", null);
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
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
