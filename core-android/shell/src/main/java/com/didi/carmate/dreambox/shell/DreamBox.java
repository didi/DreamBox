package com.didi.carmate.dreambox.shell;

import android.app.Application;
import android.content.pm.ApplicationInfo;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;

import com.didi.carmate.dreambox.core.DBEngine;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.wrapper.Wrapper;
import com.didi.carmate.dreambox.wrapper.WrapperImpl;
import com.didi.carmate.dreambox.wrapper.inner.WrapperConfig;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public final class DreamBox {

    public static final String VERSION = BuildConfig.VERSION_NAME;
    public static int VERSION_CODE = -1;
    public static Set<String> accessKeys = new HashSet<>(1);
    public static boolean Debug = true;

    private static Map<String, List<WeakReference<DreamBoxView>>> debugCache;

    private static class SingletonHolder {
        private static final DreamBox INSTANCE = new DreamBox();
    }

    public static DreamBox getInstance() {
        return SingletonHolder.INSTANCE;
    }

    private boolean initWrapper = false;
    private DreamBoxProcessor processor = new DreamBoxProcessor();

    /**
     * 初始化DreamBox,注册对应accesskey
     *
     * @param accessKey   唯一标识
     * @param application application上下文
     * @param impl        实现能力接口
     */
    public void register(@NonNull String accessKey, @NonNull Application application, @Nullable WrapperImpl impl) {
        if (!accessKeys.add(accessKey)) {
            throw new IllegalStateException(accessKey + " already register，don't need twice！");
        }
        if (!initWrapper) {
            boolean debug = (application.getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0 && Debug;
            VERSION_CODE = wrapperVersionCode(VERSION);
            Wrapper.getInstance().init(application, VERSION, debug);
            initWrapper = true;
        }
        Wrapper.getInstance().register(accessKey, impl);
        if (DBEngine.getInstance().getApplication() == null) {
            DBEngine.getInstance().init(application);
        }
    }

    public void registerDBNode(String nodeTag, INodeCreator nodeCreator) {
        DBEngine.getInstance().registerDBNode(nodeTag, nodeCreator);
    }

    public void setConfig(@NonNull String accessKey, @Nullable DreamBoxConfig config) {
        if (!accessKeys.contains(accessKey)) {
            throw new IllegalStateException(accessKey + " not register，please register it first！");
        }
        if (config == null) {
            config = new DreamBoxConfig();
        }
        WrapperConfig wrapperConfig = new WrapperConfig(config.report, config.sampleFrequency);
        Wrapper.getInstance().updateConfig(accessKey, wrapperConfig);
    }

    /**
     * 注入全局数据
     */
    public void putPoolData(@NonNull String accessKey, @NonNull String dataKey, @NonNull String dataValue) {
        DBEngine.getInstance().putGlobalProperty(accessKey, dataKey, dataValue);
    }

    @Nullable
    String process(@NonNull String accessKey, @NonNull String template) {
        try {
            return processor.process(accessKey, template);
        } catch (IllegalArgumentException e) {
            if (TextUtils.isEmpty(accessKey) || !accessKey.contains(accessKey)) {
                if (Wrapper.getInstance().debug) {
                    throw e;
                } else {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }

    void addRenderDreamBoxView(@NonNull DreamBoxView view) {
        if (!Wrapper.getInstance().debug) {
            return;
        }
        if (debugCache == null) {
            debugCache = new HashMap<>(2);
        }
        List<WeakReference<DreamBoxView>> list = debugCache.get(view.getCurAccessKey());
        if (list == null) {
            list = new ArrayList<>();
            debugCache.put(view.getCurAccessKey(), list);
        }
        for (int i = 0; i < list.size(); i++) {
            WeakReference<DreamBoxView> weakReference = list.get(i);
            if (weakReference.get() == view) {
                list.remove(i);
                break;
            }
        }
        WeakReference<DreamBoxView> weakReference = new WeakReference<>(view);
        list.add(weakReference);
    }

    @NonNull
    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public Map<String, List<String>> getAllRenderDreamBox() {
        if (debugCache == null) {
            return new HashMap<>();
        }
        Map<String, List<String>> result = new HashMap<>();
        for (String key : debugCache.keySet()) {
            List<String> temps = new ArrayList<>();
            List<WeakReference<DreamBoxView>> dbs = debugCache.get(key);
            if (dbs == null) {
                continue;
            }
            for (int i = 0; i < dbs.size(); i++) {
                DreamBoxView db = dbs.get(i).get();
                if (db == null) {
                    dbs.remove(i);
                    i--;
                } else {
                    temps.add(db.getTemplateId());
                }
            }
            result.put(key, temps);
        }
        return result;
    }

    @Nullable
    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public DreamBoxView getDreamBoxView(@NonNull String accessKey, @NonNull String templateId) {
        if (debugCache == null) {
            return null;
        }
        List<WeakReference<DreamBoxView>> dbs = debugCache.get(accessKey);
        if (dbs == null) {
            return null;
        }
        for (WeakReference<DreamBoxView> weakReference : dbs) {
            DreamBoxView db = weakReference.get();
            if (db == null) {
                continue;
            }
            if (TextUtils.equals(templateId, db.getTemplateId())) {
                return db;
            }
        }
        return null;
    }

    private static int wrapperVersionCode(@NonNull String version) {
        String[] split = version.split("\\.");
        if (split.length < 2) {
            return -1;
        }
        try {
            int firCode = Integer.parseInt(split[0]);
            int secCode = Integer.parseInt(split[1]);
            return firCode * 100 + secCode;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

}
