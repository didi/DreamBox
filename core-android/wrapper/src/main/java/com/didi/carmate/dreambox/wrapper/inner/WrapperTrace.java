package com.didi.carmate.dreambox.wrapper.inner;

import androidx.annotation.NonNull;
import androidx.annotation.RestrictTo;

import com.didi.carmate.dreambox.wrapper.Trace;

import java.util.HashMap;
import java.util.Map;

@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public class WrapperTrace {

    @NonNull
    private final Trace trace;

    public WrapperTrace(@NonNull Trace trace) {
        this.trace = trace;
    }

    public TraceAdder addTrace(String key) {
        return new TraceAdder(key);
    }

    public class TraceAdder {

        private String key;
        private Map<String, String> params = new HashMap<>(4);

        TraceAdder(String key) {
            this.key = key;
        }

        public TraceAdder add(String key, String value) {
            if (null != value) {
                params.put(key, value);
            }
            return this;
        }

        public TraceAdder addAll(Map<String, String> params) {
            if (null != params) {
                this.params.putAll(params);
            }
            return this;
        }

        public void report() {
            trace.t(key, params);
        }
    }

}
