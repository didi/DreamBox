package com.didi.carmate.dreambox.core;

import android.app.Application;
import android.content.Context;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBNodeParser;
import com.didi.carmate.dreambox.core.base.DBTemplate;

import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

import static org.junit.Assert.*;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class ExampleInstrumentedTest {
    @Test
    public void useAppContext() {
        // Context of the app under test.
        Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
        Application application = (Application) appContext.getApplicationContext();
        DBEngine.getInstance().init(application);
        String jsonStr = readFileContent(appContext, "test.json");
        DBContext dbContext = new DBContext(application, "test_access", "hello");
        DBTemplate template = new DBNodeParser().parser(dbContext,jsonStr);
        template.parserAttribute();
    }

    private String readFileContent(Context context, String fileName) {
        StringBuilder jsonSb = new StringBuilder();
        try {
            // 字节流
            InputStream is = context.getAssets().open(fileName);
            InputStreamReader isr = new InputStreamReader(is, StandardCharsets.UTF_8);
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
