package com.didi.carmate.dreambox.wrapper.inner;

import androidx.annotation.IntDef;
import androidx.annotation.NonNull;
import androidx.annotation.RestrictTo;

import com.didi.carmate.dreambox.wrapper.Monitor;
import com.didi.carmate.dreambox.wrapper.Wrapper;
import com.didi.carmate.dreambox.wrapper.util.DBCodeUtil;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public class WrapperMonitor {

    // 在App周期内，一个模板上报一次
    public static final int TRACE_NUM_ONCE = 1;
    // 采样上报，取决于设置上报频率
    public static final int TRACE_NUM_SAMPLE = 2;
    // 每次上报，报告异常
    public static final int TRACE_NUM_EVERY = 3;

    @Retention(RetentionPolicy.SOURCE)
    @IntDef({TRACE_NUM_ONCE, TRACE_NUM_SAMPLE, TRACE_NUM_EVERY})
    public @interface TraceType {

    }

    private WrapperInner wrapperInner;
    private String accessKey;
    private Monitor monitor;
    private Map<String, Set<String>> reportKeys = new HashMap<>(4);

    public WrapperMonitor(@NonNull WrapperInner wrapperInner, @NonNull String accessKey, @NonNull Monitor monitor) {
        this.wrapperInner = wrapperInner;
        this.accessKey = accessKey;
        this.monitor = monitor;
    }

    // 暂不实现
    public void crash(@NonNull Exception error) {
        throw new RuntimeException(error);
    }

    public ReportAdder report(@NonNull String templateId, @NonNull String key, @TraceType int type) {
        return new ReportAdder(templateId, key, type);
    }

    public ReportStart start(@NonNull String templateId, @NonNull String key, @TraceType int type) {
        return new ReportStart(templateId, key, type);
    }

    public class ReportStart {

        private String templateId, key;
        @TraceType
        private int type;
        private long startTime;

        private ReportAdder adder;

        ReportStart(String templateId, String key, @TraceType int type) {
            this.templateId = templateId;
            this.key = key;
            this.type = type;
            this.startTime = System.currentTimeMillis();
        }

        public ReportAdder adder() {
            if (adder == null) {
                adder = report(templateId, key, type);
            }
            return adder;
        }

        public ReportAdder stop() {
            if (adder == null) {
                adder = report(templateId, key, type);
            }
            if (startTime > 0) {
                long diff = System.currentTimeMillis() - startTime;
                adder.add("duration", String.valueOf(diff));
                startTime = -1;
            }
            return adder;
        }
    }

    public class ReportAdder {


        private String templateId, key;
        @TraceType
        private int type;
        private Map<String, String> params = new HashMap<>(4);

        ReportAdder(String templateId, String key, @TraceType int type) {
            this.templateId = templateId;
            this.key = key;
            this.type = type;
        }

        public ReportAdder add(String key, String value) {
            if (null != value) {
                params.put(key, value);
            }
            return this;
        }

        public ReportAdder addAll(Map<String, String> params) {
            if (null != params) {
                this.params.putAll(params);
            }
            return this;
        }

        public void report() {
            if (!wrapperInner.config.report) {
                return;
            }
            switch (type) {
                case TRACE_NUM_ONCE:
                    Set<String> storeKeys = reportKeys.get(templateId);
                    if (storeKeys == null) {
                        storeKeys = new HashSet<>();
                        reportKeys.put(templateId, storeKeys);
                    }
                    if (!storeKeys.add(key)) {
                        return;
                    }
                    break;
                case TRACE_NUM_SAMPLE:
                    if (Math.random() >= wrapperInner.config.sampleFrequency) {
                        return;
                    }
                    break;
                case TRACE_NUM_EVERY:
                default:
                    break;
            }
            params.put("uuid", Wrapper.getInstance().uuid);
            params.put("version", Wrapper.getInstance().version);
            params.put("access_key", accessKey);
            params.put("template_id", DBCodeUtil.md5FromCache(templateId));
            params.put("debug", Wrapper.getInstance().debug ? "1" : "0");

            monitor.report(key, params);
        }
    }
}
