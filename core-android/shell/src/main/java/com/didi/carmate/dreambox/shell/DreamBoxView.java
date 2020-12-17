package com.didi.carmate.dreambox.shell;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Looper;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import androidx.annotation.WorkerThread;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import com.didi.carmate.dreambox.core.DBEngine;
import com.didi.carmate.dreambox.core.base.DBTemplate;
import com.didi.carmate.dreambox.core.base.IDBCoreView;
import com.didi.carmate.dreambox.core.bridge.IDBEventReceiver;
import com.didi.carmate.dreambox.core.utils.DBThreadUtils;
import com.didi.carmate.dreambox.wrapper.Template;
import com.didi.carmate.dreambox.wrapper.Wrapper;
import com.didi.carmate.dreambox.wrapper.inner.WrapperMonitor;
import com.google.gson.JsonObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;

public class DreamBoxView extends FrameLayout implements LifecycleOwner {

    private static final String TAG = "DreamBoxView";

    public interface OnRenderCallback {
        void onRender(boolean success);
    }

    private static final int FAIL_LOAD_TEMPLATE = 101;      // 加载模板数据失败
    private static final int FAIL_TEMPLATE_PROCESS = 102;   // 解析模板数据失败
    private static final int FAIL_RENDER_TEMPLATE = 103;    // 渲染模板视图失败

    @Nullable
    private volatile IDBCoreView curCoreView;
    private Lifecycle curLifecycle;
    private String curAccessKey;

    private volatile String curTemplateId;
    private volatile String curExt;

    private volatile String storeExt;
    private Map<String, String> storeSendEvent;
    private Map<String, IDBEventReceiver> storeRegisterEvent;


    public DreamBoxView(@NonNull Context context) {
        this(context, null);
    }

    public DreamBoxView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public DreamBoxView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        addDebugView();
    }

    @SuppressLint("ClickableViewAccessibility")
    private void addDebugView() {
        if (Wrapper.getInstance().debug) {
            ImageView imageView = new ImageView(getContext());
            imageView.setImageResource(R.drawable.dreambox_debug_icon);
            LayoutParams layoutParams = new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            layoutParams.gravity = Gravity.END;
            addView(imageView, layoutParams);
        } else {
            int len = (int) (40 * getResources().getDisplayMetrics().density + 0.5f);
            View view = new View(getContext());
            LayoutParams layoutParams = new LayoutParams(len, len);
            layoutParams.gravity = Gravity.END;
            addView(view, layoutParams);
            view.setOnTouchListener(new OnTouchListener() {

                private int index;
                private long lastDownTime;

                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    if (event.getAction() == MotionEvent.ACTION_DOWN) {
                        if (System.currentTimeMillis() - lastDownTime > 1000) {
                            index = 0;
                        }
                        index++;
                        lastDownTime = System.currentTimeMillis();
                        if (index > 10) {
                            index = 0;
                            lastDownTime = 0;
                            Toast.makeText(getContext(), "this is db view!", Toast.LENGTH_SHORT).show();
                        }
                    }
                    return false;
                }
            });
        }
    }

    public void render(@NonNull String accessKey, @NonNull String templateId,
                       @Nullable OnRenderCallback callback) {
        render(accessKey, templateId, null, callback);
    }

    public void render(@NonNull String accessKey, @NonNull String templateId, @Nullable String extJsonStr,
                       @Nullable OnRenderCallback callback) {
        Context context = getContext();
        if (context instanceof FragmentActivity) {
            render(accessKey, templateId, extJsonStr, callback, ((FragmentActivity) context).getLifecycle());
        } else {
            throw new IllegalStateException("DreamBox need lifecycle to render");
        }
    }

    public void render(@NonNull final String accessKey, @NonNull final String templateId, @Nullable final String extJsonStr,
                       @Nullable final OnRenderCallback callback, @NonNull final Lifecycle lifecycle) {
        if (TextUtils.isEmpty(accessKey)) {
            throw new IllegalArgumentException("please set accessKey before use");
        }

        final WrapperMonitor.ReportStart totalRenderReport = Wrapper.get(accessKey).monitor()
                .start(templateId, "tech_db_duration_render_total", WrapperMonitor.TRACE_NUM_SAMPLE);

        this.curAccessKey = accessKey;
        this.curTemplateId = templateId;
        this.curLifecycle = lifecycle;
        this.curCoreView = null;
        this.storeExt = null;

        DBThreadUtils.runOnWork(new Runnable() {
            @Override
            public void run() {
                // 尝试从外部加载模板数据
                final long startLoadTemplate = System.currentTimeMillis();
                Wrapper.get(accessKey).template().loadTemplate(templateId, new Template.Callback() {
                    @Override
                    public void onLoadTemplate(@Nullable String template) {
                        // 外部无模板，尝试读取本地dbt文件
                        if (TextUtils.isEmpty(template)) {
                            template = getStringFromAssets(getContext(), "local." + templateId + ".dbt");
                        }
                        if (TextUtils.isEmpty(template)) {
                            renderCallbackOnMain(callback, false, FAIL_LOAD_TEMPLATE, "template not found");
                            return;
                        }

                        long loadTemplateTime = System.currentTimeMillis() - startLoadTemplate;
                        totalRenderReport.adder().add("get_temp_time", loadTemplateTime + "");

                        renderWithTemplate(templateId, callback, template, extJsonStr, totalRenderReport);
                    }
                });
            }
        });
        DreamBox.getInstance().addRenderDreamBoxView(this);
    }

    public void setExtJsonStr(@NonNull final String extJsonStr) {
        if (curCoreView == null) {
            this.storeExt = extJsonStr;
        } else {
            curExt = extJsonStr;
            DBThreadUtils.runOnWork(new Runnable() {
                @Override
                public void run() {
                    if (!TextUtils.equals(curExt, extJsonStr)) {
                        // 防止异步线程时序不一致
                        Log.w(TAG, "render ext is not same cur-" + curExt + "，this-" + extJsonStr);
                        return;
                    }
                    if (curCoreView == null) {
                        Log.w(TAG, "update ext but core view is empty，wait next render");
                        return;
                    }
                    JsonObject ext = DBEngine.getInstance().extWrapper(extJsonStr);
                    curCoreView.setExtData(ext);
                    DBThreadUtils.runOnMain(new Runnable() {
                        @Override
                        public void run() {
                            if (curCoreView != null) {
                                curCoreView.requestRender();
                            } else {
                                Log.w(TAG, "reload render but core view is empty，wait next render");
                            }
                        }
                    });
                }
            });
        }
    }

    @WorkerThread
    private void renderWithTemplate(final String templateId, final OnRenderCallback callback,
                                    String template, final String extJsonStr, final WrapperMonitor.ReportStart totalRenderReport) {
        // 解析db模板数据，获取真正模板
        final String temp = DreamBox.getInstance().process(curAccessKey, template);
        if (TextUtils.isEmpty(temp)) {
            renderCallbackOnMain(callback, false, FAIL_TEMPLATE_PROCESS, "process template fail");
            return;
        }

        // 后台解析模板
        final DBTemplate dbTemplate = DBEngine.getInstance().parser(curAccessKey, templateId, temp);

        JsonObject ext = null;
        if (extJsonStr != null) {
            ext = DBEngine.getInstance().extWrapper(extJsonStr);
        }
        final JsonObject renderExt = ext;

        DBThreadUtils.runOnMain(new Runnable() {
            @Override
            public void run() {
                // 检查，防止异步造成时序不一致
                if (!TextUtils.equals(curTemplateId, templateId)) {
                    Log.w(TAG, "render templateId is not same cur-" + curTemplateId + "，this-" + templateId);
                    return;
                }

                // 构建核心视图
                IDBCoreView coreView = DBEngine.getInstance().render(dbTemplate, renderExt, getContext(), curLifecycle);
                if (coreView == null) {
                    renderCallbackOnMain(callback, false, FAIL_RENDER_TEMPLATE, "render view fail");
                    return;
                }

                curExt = extJsonStr;
                // 替换为实际view
                renderView(coreView);

                // 渲染完成后，再更新外部设置数据
                if (storeExt != null) {
                    setExtJsonStr(storeExt);
                    storeExt = null;
                }

                if (totalRenderReport != null) {
                    totalRenderReport.stop().report();
                }
                renderCallbackOnMain(callback, true, 0, "");

                // 渲染完成后，可以进行发送事件与与注册事件
                if (storeSendEvent != null) {
                    for (Map.Entry<String, String> send : storeSendEvent.entrySet()) {
                        sendEvent(send.getKey(), send.getValue());
                    }
                    storeSendEvent = null;
                }
                if (storeRegisterEvent != null) {
                    for (Map.Entry<String, IDBEventReceiver> send : storeRegisterEvent.entrySet()) {
                        registerEventReceiver(send.getKey(), send.getValue());
                    }
                    storeRegisterEvent = null;
                }
            }
        });
    }

    private void renderCallbackOnMain(final OnRenderCallback callback, final boolean success, int code, String reason) {
        Wrapper.get(curAccessKey).monitor()
                .report(curTemplateId, "tech_duration_render_result", WrapperMonitor.TRACE_NUM_EVERY)
                .add("success", String.valueOf(success ? 1 : 0))
                .add("code", String.valueOf(code))
                .add("reason", reason)
                .report();
        if (callback == null) {
            return;
        }
        if (Thread.currentThread() == Looper.getMainLooper().getThread()) {
            callback.onRender(success);
        } else {
            DBThreadUtils.runOnMain(new Runnable() {
                @Override
                public void run() {
                    callback.onRender(success);
                }
            });
        }
    }

    private void renderView(IDBCoreView view) {
        removeAllViews();
        this.curCoreView = view;
        addView(curCoreView.getView(), 0,
                new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        addDebugView();
    }

    @WorkerThread
    private String getStringFromAssets(Context context, String fileName) {
        StringBuilder content = new StringBuilder();
        try {
            // 字节流
            InputStream is = context.getAssets().open(fileName);
            InputStreamReader isr = new InputStreamReader(is, "UTF-8");
            BufferedReader bfr = new BufferedReader(isr);

            String in;
            while ((in = bfr.readLine()) != null) {
                content.append(in);
            }
            is.close();
            isr.close();
            bfr.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return content.toString();
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
        return curLifecycle;
    }

    public void sendEvent(String eventId, String msgTo) {
        if (curCoreView != null) {
            curCoreView.sendEvent(eventId, msgTo);
        } else {
            if (storeSendEvent == null) {
                storeSendEvent = new HashMap<>();
            }
            storeSendEvent.put(eventId, msgTo);
        }
    }

    public void registerEventReceiver(String eventId, IDBEventReceiver eventReceiver) {
        if (curCoreView != null) {
            curCoreView.registerEventReceiver(eventId, eventReceiver);
        } else {
            if (storeRegisterEvent == null) {
                storeRegisterEvent = new HashMap<>();
            }
            storeRegisterEvent.put(eventId, eventReceiver);
        }
    }

    @WorkerThread
    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public void reloadWithTemplate(String template) {
        renderWithTemplate(curTemplateId, null, template, curExt, null);
    }

    public String getCurAccessKey() {
        return curAccessKey;
    }

    public String getTemplateId() {
        return curTemplateId;
    }
}
