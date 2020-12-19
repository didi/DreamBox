package com.didi.carmate.dreambox.core.base;

import android.content.Context;
import android.os.Looper;

import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;

import com.didi.carmate.dreambox.core.action.DBActionAliasItem;
import com.didi.carmate.dreambox.core.bridge.DBOnEvent;
import com.didi.carmate.dreambox.core.utils.DBThreadUtils;
import com.google.gson.JsonObject;

import java.util.List;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBTemplate extends DBNode implements LifecycleObserver {
    private Lifecycle mLifecycle;
    private final DBContext mDBContext;
    private com.didi.carmate.dreambox.core.constraint.render.DBLView mConstraintDBL;
    private com.didi.carmate.dreambox.core.layout.render.DBLView mYogaDBL;

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
        if (null != mConstraintDBL) {
            mConstraintDBL.onCreate();
        }
        if (null != mYogaDBL) {
            mYogaDBL.onCreate();
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    public void onResume() {
        if (null != mConstraintDBL) {
            mConstraintDBL.onResume();
        }
        if (null != mYogaDBL) {
            mYogaDBL.onResume();
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    public void onPause() {
        if (null != mConstraintDBL) {
            mConstraintDBL.onPause();
        }
        if (null != mYogaDBL) {
            mYogaDBL.onPause();
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    public void onDestroy() {
        if (null != mConstraintDBL) {
            mConstraintDBL.onDestroy();
        }
        if (null != mYogaDBL) {
            mYogaDBL.onDestroy();
        }
        // 资源释放
        release();
    }

    @Override
    public void release() {
        if (null != mConstraintDBL) {
            mConstraintDBL.release();
        }
        if (null != mYogaDBL) {
            mYogaDBL.release();
        }
        // 释放Activity
        if (null != mDBContext && null != mLifecycle) {
            mLifecycle.removeObserver(this);
            mDBContext.release();
        }
    }

    public DBOnEvent getDBOnEvent() {
        if (null != mConstraintDBL) {
            return mConstraintDBL.getDBOnEvent();
        }
        if (null != mYogaDBL) {
            return mYogaDBL.getDBOnEvent();
        }
        return null;
    }

    /**
     * 重新刷新整个模板
     */
    public void invalidate() {
        if (null != mConstraintDBL) {
            mConstraintDBL.invalidate();
        }
        if (null != mYogaDBL) {
            mYogaDBL.invalidate();
        }
    }

    public List<DBActionAliasItem> getActionAliasItems() {
        if (null != mConstraintDBL) {
            return mConstraintDBL.getActionAliasItems();
        }
        if (null != mYogaDBL) {
            return mYogaDBL.getActionAliasItems();
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

        if (null == mConstraintDBL) {
            List<IDBNode> children = getChildren();
            for (IDBNode child : children) {
                if (child instanceof com.didi.carmate.dreambox.core.constraint.render.DBLView) {
                    mConstraintDBL = (com.didi.carmate.dreambox.core.constraint.render.DBLView) child;
                    break;
                }
            }
        }

        if (null == mYogaDBL) {
            List<IDBNode> children = getChildren();
            for (IDBNode child : children) {
                if (child instanceof com.didi.carmate.dreambox.core.layout.render.DBLView) {
                    mYogaDBL = (com.didi.carmate.dreambox.core.layout.render.DBLView) child;
                    break;
                }
            }
        }
    }

    public IDBCoreView getDBCoreView() {
        if (null != mConstraintDBL) {
            return mConstraintDBL.getDBCoreView();
        }
        if (null != mYogaDBL) {
            return mYogaDBL.getDBCoreView();
        }
        return null;
    }
}
