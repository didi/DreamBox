package com.didi.carmate.dreambox.wrapper.v4.impl;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;
import com.didi.carmate.dreambox.wrapper.v4.Dialog;
import com.didi.carmate.dreambox.wrapper.v4.ImageLoader;
import com.didi.carmate.dreambox.wrapper.v4.Log;
import com.didi.carmate.dreambox.wrapper.v4.Monitor;
import com.didi.carmate.dreambox.wrapper.v4.Navigator;
import com.didi.carmate.dreambox.wrapper.v4.Net;
import com.didi.carmate.dreambox.wrapper.v4.Storage;
import com.didi.carmate.dreambox.wrapper.v4.Template;
import com.didi.carmate.dreambox.wrapper.v4.Toast;
import com.didi.carmate.dreambox.wrapper.v4.Trace;
import com.didi.carmate.dreambox.wrapper.v4.Wrapper;
import com.didi.carmate.dreambox.wrapper.v4.WrapperImpl;

import java.io.UnsupportedEncodingException;
import java.util.Map;

@Keep
public class SimpleWrapper extends WrapperImpl {

    private static final String TAG = "SimpleWrapper";

    private RequestQueue requestQueue;
    private SharedPreferences sp;

    private final Log logImpl = new Log() {
        @Override
        public void v(@NonNull String msg) {
            android.util.Log.v(TAG, msg);
        }

        @Override
        public void d(@NonNull String msg) {
            android.util.Log.d(TAG, msg);
        }

        @Override
        public void i(@NonNull String msg) {
            android.util.Log.i(TAG, msg);
        }

        @Override
        public void w(@NonNull String msg) {
            android.util.Log.w(TAG, msg);
        }

        @Override
        public void e(@NonNull String msg) {
            android.util.Log.e(TAG, msg);
        }
    };

    private Net netImpl = new Net() {
        @Override
        public void get(@NonNull String url, @Nullable final Callback cb) {
            if (requestQueue == null) {
                try {
                    Class.forName("com.android.volley.toolbox.Volley");
                } catch (ClassNotFoundException e) {
                    throw new RuntimeException("you need compile com.android.volley:volley " +
                            "or use custom wrapper overload net()!", e);
                }
                requestQueue = Volley.newRequestQueue(Wrapper.getInstance().application);
            }
            requestQueue.add(
                    new StringRequest(Request.Method.GET, url,
                            new Response.Listener<String>() {
                                @Override
                                public void onResponse(final String response) {
                                    if (cb != null) {
                                        // 将数据转码为UTF-8，解决中文乱码问题
                                        try {
                                            String utf8Resp = new String(response.getBytes("ISO-8859-1"), "UTF-8");
                                            cb.onSuccess(utf8Resp);
                                        } catch (UnsupportedEncodingException e) {
                                            e.printStackTrace();
                                        }
                                    }
                                }
                            },
                            new Response.ErrorListener() {
                                @Override
                                public void onErrorResponse(VolleyError error) {
                                    if (error != null && error.networkResponse != null) {
                                        if (cb != null) {
                                            cb.onError(error.networkResponse.statusCode, error);
                                        }
                                    } else {
                                        if (cb != null) {
                                            cb.onError(-1, null);
                                        }
                                    }
                                }
                            }));
        }
    };

    private final ImageLoader imageLoaderImpl = new ImageLoader() {

        private boolean isInit = false;

        private void checkInit() {
            if (!isInit) {
                try {
                    Class.forName("com.bumptech.glide.Glide");
                } catch (ClassNotFoundException e) {
                    throw new RuntimeException("you need compile com.github.bumptech.glide:glide " +
                            "or use custom wrapper overload imageLoader()!", e);
                }
                isInit = true;
            }
        }

        @Override
        public void load(@NonNull final String url, final @NonNull ImageView imageView) {
            checkInit();
            Glide.with(imageView).load(url).into(imageView);
        }

        @Override
        public void load(@NonNull final String url, final @NonNull View view) {
            checkInit();
            Glide.with(view).load(url).into(new CustomTarget<Drawable>() {
                @Override
                public void onResourceReady(@NonNull Drawable resource, @Nullable Transition<? super Drawable> transition) {
                    view.setBackground(resource);
                }

                @Override
                public void onLoadCleared(@Nullable Drawable placeholder) {
                }
            });
        }
    };

    private final Monitor monitorImpl = new Monitor() {

        @Override
        public void report(@NonNull String type, @Nullable Map<String, String> params) {
            StringBuilder builder = new StringBuilder(type);
            if (params != null) {
                builder.append(" ==> ");
                for (String key : params.keySet()) {
                    builder.append("\n").append(key).append(" : ").append(params.get(key));
                }
            }
            logImpl.i(builder.toString());
        }

    };

    private final Trace traceImpl = new Trace() {
        @Override
        public void t(@NonNull String key, @Nullable Map<String, String> attrs) {
            StringBuilder builder = new StringBuilder(key);
            if (attrs != null) {
                for (Map.Entry<String, String> attr : attrs.entrySet()) {
                    builder.append("\n").append(attr.getKey()).append(":").append(attr.getValue());
                }
            }
            logImpl.i(builder.toString());
        }
    };

    private final Storage storageImpl = new Storage() {
        @Override
        public void put(@NonNull String key, @NonNull String value) {
            sp.edit().putString(key, value).apply();
        }

        @Override
        public String get(@NonNull String key, @NonNull String defaultValue) {
            return sp.getString(key, defaultValue);
        }
    };

    private final Toast toastImpl = new Toast() {
        @Override
        public void show(@NonNull Context context, @NonNull String msg, boolean durationLong) {
            android.widget.Toast.makeText(context, msg, durationLong ? android.widget.Toast.LENGTH_LONG : android.widget.Toast.LENGTH_SHORT).show();
        }
    };

    private final Dialog dialogImpl = new Dialog() {
        @Override
        public void show(@NonNull Context context, @Nullable String title, @Nullable String msg,
                         @Nullable String positiveBtn, @Nullable final String negativeBtn,
                         @Nullable final OnClickListener posListener, @Nullable final OnClickListener negListener) {
            new AlertDialog
                    .Builder(context)
                    .setTitle(title)
                    .setMessage(msg)
                    .setPositiveButton(positiveBtn, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            if (posListener != null) {
                                posListener.onClick();
                            }
                        }
                    })
                    .setNegativeButton(negativeBtn, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            if (negListener != null) {
                                negListener.onClick();
                            }
                        }
                    })
                    .show();
        }
    };

    private final Navigator navigatorImpl = new Navigator() {
        @Override
        public void navigator(@NonNull Context context, @NonNull String url) {
            try {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(url));
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    public SimpleWrapper() {
        sp = Wrapper.getInstance().application.getSharedPreferences("db_cache", Context.MODE_PRIVATE);
    }

    @Override
    public Template template() {
        return null;
    }

    @Override
    public Log log() {
        return logImpl;
    }

    @Override
    public Navigator navigator() {
        return navigatorImpl;
    }

    @Override
    public Net net() {
        return netImpl;
    }

    @Override
    public ImageLoader imageLoader() {
        return imageLoaderImpl;
    }

    @Override
    public Monitor monitor() {
        return monitorImpl;
    }

    @Override
    public Trace trace() {
        return traceImpl;
    }

    @Override
    public Storage storage() {
        return storageImpl;
    }

    @Override
    public Toast toast() {
        return toastImpl;
    }

    @Override
    public Dialog dialog() {
        return dialogImpl;
    }
}
