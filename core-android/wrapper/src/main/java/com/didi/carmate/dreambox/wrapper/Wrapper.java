package com.didi.carmate.dreambox.wrapper;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;

import com.didi.carmate.dreambox.wrapper.inner.WrapperConfig;
import com.didi.carmate.dreambox.wrapper.inner.WrapperInner;
import com.didi.carmate.dreambox.wrapper.inner.WrapperUtils;

import java.util.HashMap;
import java.util.Map;

@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public class Wrapper {

    private static volatile Wrapper mInstance;

    public static Wrapper getInstance() {
        if (mInstance == null) {
            synchronized (Wrapper.class) {
                if (mInstance == null) {
                    mInstance = new Wrapper();
                }
            }
        }
        return mInstance;
    }

    public static WrapperInner get(@NonNull String accessKey) {
        WrapperInner wrapper = getInstance().implMap.get(accessKey);
        if (wrapper == null) {
            throw new NullPointerException("here is none WrapperImpl fond，please check already register accessKey " + accessKey);
        }
        return wrapper;
    }

    public Application application;
    public String version;
    public boolean debug;
    public String uuid;

    private WrapperImpl simpleImpl;
    private Map<String, WrapperInner> implMap = new HashMap<>(1);

    private Wrapper() {
    }

    public void init(Application application, String version, int versionCode, boolean debug) {
        this.application = application;
        this.version = version;
        this.debug = debug;
        uuid = WrapperUtils.getUUID(application);
    }

    public void updateConfig(@NonNull String accessKey, @Nullable WrapperConfig config) {
        WrapperInner wrapper = implMap.get(accessKey);
        if (wrapper == null) {
            throw new NullPointerException("here is none WrapperImpl fond，please check already register accessKey " + accessKey);
        }
        wrapper.setConfig(config);
    }

    public void register(@NonNull String accessKey, @Nullable WrapperImpl impl) {
        if (simpleImpl == null) {
            simpleImpl = getDefaultImpl();
        }
        implMap.put(accessKey, new WrapperInner(accessKey, impl, simpleImpl));
    }

    private static WrapperImpl getDefaultImpl() {
        try {
            Class cls = Class.forName("com.didi.carmate.dreambox.wrapper.impl.SimpleWrapper");
            Object impl = cls.newInstance();
            if (impl instanceof WrapperImpl) {
                return (WrapperImpl) impl;
            } else {
                throw new IllegalStateException("SimpleWrapper并不是WrapperImpl类型，请检查相关代码");
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new IllegalStateException("为找到Wrapper实现，请引入simple-wrapper或通过Wrapper#init()注册自己的实现");
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            throw new IllegalStateException("反射构造Wrapper失败，请确认simple-wrapper中构造器声明可以被正确反射到");
        } catch (InstantiationException e) {
            e.printStackTrace();
            throw new IllegalStateException("反射构造Wrapper失败，请确认simple-wrapper中构造器声明可以被正确反射到");
        }
    }


}
