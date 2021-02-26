package com.didi.carmate.dreambox.core.v4.base;

import android.content.Context;
import android.os.Looper;

import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;

import com.didi.carmate.dreambox.core.v4.action.DBActionAliasItem;
import com.didi.carmate.dreambox.core.v4.bridge.DBOnEvent;
import com.didi.carmate.dreambox.core.v4.render.DBLView;
import com.didi.carmate.dreambox.core.v4.utils.DBThreadUtils;
import com.google.gson.JsonObject;

import java.util.List;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBTemplate extends DBNode implements LifecycleObserver {
    private Lifecycle mLifecycle;
    private final DBContext mDBContext;
    private com.didi.carmate.dreambox.core.v4.render.DBLView mDBL;

    public DBTemplate(DBContext dbContext) {
        super(dbContext);
        mDBContext = dbContext;
        dbContext.setDBTemplate(this);
    }

    public void setExtJsonObject(JsonObject extJsonObject) {
        mDBContext.setExtJsonObject(extJsonObject);
    }

    public void setCurrentContext(Context currentContext) {
        mDBContext.setCurrentContext(currentContext);
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
    public void onCreate() {
        if (null != mDBL) {
            mDBL.onCreate();
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    public void onResume() {
        if (null != mDBL) {
            mDBL.onResume();
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    public void onPause() {
        if (null != mDBL) {
            mDBL.onPause();
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    public void onDestroy() {
        if (null != mDBL) {
            mDBL.onDestroy();
        }
        // 资源释放
        release();
    }

    @Override
    public void release() {
        if (null != mDBL) {
            mDBL.release();
        }
        // 释放Activity
        if (null != mDBContext && null != mLifecycle) {
            mLifecycle.removeObserver(this);
            mDBContext.release();
        }
    }

    public DBOnEvent getDBOnEvent() {
        if (null != mDBL) {
            return mDBL.getDBOnEvent();
        }
        return null;
    }

    /**
     * 重新刷新整个模板
     */
    public void invalidate() {
        if (null != mDBL) {
            mDBL.invalidate();
        }
    }

    /**
     * 刷新整数据
     */
    public void bindData() {
        if (null != mDBL) {
            mDBL.bindData();
        }
    }

    public List<DBActionAliasItem> getActionAliasItems() {
        if (null != mDBL) {
            return mDBL.getActionAliasItems();
        }
        return null;
    }

    /**
     * 绑定承载模板对象Activity的生命周期
     */
    public void bindLifecycle(final Lifecycle lifecycle) {
        mLifecycle = lifecycle;

        if (Thread.currentThread() == Looper.getMainLooper().getThread()) {
            lifecycle.addObserver(this);
        } else {
            DBThreadUtils.runOnMain(new Runnable() {
                @Override
                public void run() {
                    lifecycle.addObserver(DBTemplate.this);
                }
            });
        }
    }

    @Override
    public void onParserNode() {
        super.onParserNode();

        if (null == mDBL) {
            List<IDBNode> children = getChildren();
            for (IDBNode child : children) {
                if (child instanceof DBLView) {
                    mDBL = (DBLView) child;
                    break;
                }
            }
        }
    }

    public IDBCoreView getDBCoreView() {
        if (null != mDBL) {
            return mDBL.getDBCoreView();
        }
        return null;
    }
}
