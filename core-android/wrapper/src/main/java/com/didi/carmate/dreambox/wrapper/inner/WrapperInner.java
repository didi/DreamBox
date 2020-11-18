package com.didi.carmate.dreambox.wrapper.inner;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;

import com.didi.carmate.dreambox.wrapper.Dialog;
import com.didi.carmate.dreambox.wrapper.ImageLoader;
import com.didi.carmate.dreambox.wrapper.Log;
import com.didi.carmate.dreambox.wrapper.Monitor;
import com.didi.carmate.dreambox.wrapper.Navigator;
import com.didi.carmate.dreambox.wrapper.Net;
import com.didi.carmate.dreambox.wrapper.Storage;
import com.didi.carmate.dreambox.wrapper.Template;
import com.didi.carmate.dreambox.wrapper.Toast;
import com.didi.carmate.dreambox.wrapper.Trace;
import com.didi.carmate.dreambox.wrapper.WrapperImpl;

@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public class WrapperInner {

    private String accessKey;
    @Nullable
    private WrapperImpl impl;
    @Nullable
    private WrapperImpl simple;

    @NonNull
    WrapperConfig config = new WrapperConfig();

    private Template template;
    private Log log;
    private Navigator navigator;
    private Net net;
    private ImageLoader imageLoader;
    private Storage storage;
    private Toast toast;
    private Dialog dialog;
    private WrapperMonitor monitor;
    private WrapperTrace trace;

    public WrapperInner(@NonNull String accessKey, @Nullable WrapperImpl impl, @Nullable WrapperImpl simple) {
        this.accessKey = accessKey;
        this.impl = impl;
        this.simple = simple;
    }

    public void setConfig(@Nullable WrapperConfig config) {
        if (config == null) {
            config = new WrapperConfig();
        }
        this.config = config;
    }

    @NonNull
    public Template template() {
        if (template == null) {
            template = impl == null ? null : impl.template();
        }
        if (template == null) {
            template = simple == null ? null : simple.template();
        }
        if (template == null) {
            template = Template.empty;
        }
        return template;
    }

    @NonNull
    public Log log() {
        if (log == null) {
            log = impl == null ? null : impl.log();
        }
        if (log == null) {
            log = simple == null ? null : simple.log();
        }
        if (log == null) {
            log = Log.empty;
        }
        return log;
    }

    @NonNull
    public Navigator navigator() {
        if (navigator == null) {
            navigator = impl == null ? null : impl.navigator();
        }
        if (navigator == null) {
            navigator = simple == null ? null : simple.navigator();
        }
        if (navigator == null) {
            navigator = Navigator.empty;
        }
        return navigator;
    }

    @NonNull
    public Net net() {
        if (net == null) {
            net = impl == null ? null : impl.net();
        }
        if (net == null) {
            net = simple == null ? null : simple.net();
        }
        if (net == null) {
            net = Net.empty;
        }
        return net;
    }

    @NonNull
    public ImageLoader imageLoader() {
        if (imageLoader == null) {
            imageLoader = impl == null ? null : impl.imageLoader();
        }
        if (imageLoader == null) {
            imageLoader = simple == null ? null : simple.imageLoader();
        }
        if (imageLoader == null) {
            imageLoader = ImageLoader.empty;
        }
        return imageLoader;
    }

    @NonNull
    public WrapperMonitor monitor() {
        if (monitor == null) {
            Monitor monitorImpl = impl == null ? null : impl.monitor();
            if (monitorImpl == null) {
                monitorImpl = simple == null ? null : simple.monitor();
            }
            if (monitorImpl == null) {
                monitorImpl = Monitor.empty;
            }
            monitor = new WrapperMonitor(this, accessKey, monitorImpl);
        }
        return monitor;
    }

    @NonNull
    public WrapperTrace trace() {
        if (trace == null) {
            Trace implTrace = impl == null ? null : impl.trace();
            if (implTrace == null) {
                implTrace = simple == null ? null : simple.trace();
            }
            if (implTrace == null) {
                implTrace = Trace.empty;
            }
            trace = new WrapperTrace(implTrace);
        }
        return trace;
    }

    @NonNull
    public Storage storage() {
        if (storage == null) {
            storage = impl == null ? null : impl.storage();
        }
        if (storage == null) {
            storage = simple == null ? null : simple.storage();
        }
        if (storage == null) {
            storage = Storage.empty;
        }
        return storage;
    }

    @NonNull
    public Toast toast() {
        if (toast == null) {
            toast = impl == null ? null : impl.toast();
        }
        if (toast == null) {
            toast = simple == null ? null : simple.toast();
        }
        if (toast == null) {
            toast = Toast.empty;
        }
        return toast;
    }

    @NonNull
    public Dialog dialog() {
        if (dialog == null) {
            dialog = impl == null ? null : impl.dialog();
        }
        if (dialog == null) {
            dialog = simple == null ? null : simple.dialog();
        }
        if (dialog == null) {
            dialog = Dialog.empty;
        }
        return dialog;
    }

}
