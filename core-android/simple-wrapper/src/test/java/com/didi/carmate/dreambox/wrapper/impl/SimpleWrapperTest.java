package com.didi.carmate.dreambox.wrapper.impl;

import android.content.Context;
import android.os.Build;

import androidx.test.core.app.ApplicationProvider;

import com.didi.carmate.dreambox.wrapper.v4.impl.SimpleWrapper;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

import static org.junit.Assert.*;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class SimpleWrapperTest {

    private Context context = ApplicationProvider.getApplicationContext();

    @Test
    public void testClassName() {
        assertEquals("com.didi.carmate.dreambox.wrapper.v4.impl.SimpleWrapper", SimpleWrapper.class.getCanonicalName());
    }

    @Test
    public void testInit() {
        SimpleWrapper wrapper = new SimpleWrapper();

        assertNotNull(context);
        wrapper.init(context);
    }
}