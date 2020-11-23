package com.didi.carmate.dreambox.core.base;

import android.view.View;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.action.IDBAction;
import com.didi.carmate.dreambox.core.data.DBData;
import com.didi.carmate.dreambox.core.render.DBChildren;
import com.didi.carmate.dreambox.core.render.view.DBRootView;
import com.didi.carmate.dreambox.core.utils.DBLogger;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public abstract class DBBaseView<V extends View> extends DBAbsView<V> {
    // chain
    private String chainStyle;
    private DBBaseView<?> nextNode; // 用于确定chain的方向
    //    private String backgroundUrl;

    // View callback节点集合
    private final List<DBCallback> mCallbacks = new ArrayList<>();
    private final List<DBContainer<?>> mChildContainers = new ArrayList<>();

    protected DBBaseView(DBContext dbContext) {
        super(dbContext);
    }

    public String getChainStyle() {
        return chainStyle;
    }

    public DBBaseView<?> getNextNode() {
        return nextNode;
    }

    public void setNextNode(DBBaseView<?> nextNode) {
        this.nextNode = nextNode;
    }

    @Override
    protected void onParserNode() {
        super.onParserNode();

        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof DBCallbacks) { // callback 集合
                List<IDBNode> callbacks = child.getChildren();
                for (IDBNode callback : callbacks) {
                    if (callback instanceof DBCallback) {
                        mCallbacks.add((DBCallback) callback);
                    }
                }
            } else if (child instanceof DBChildren) { // 子容器视图集合
                List<IDBNode> containers = child.getChildren();
                for (IDBNode container : containers) {
                    if (container instanceof DBContainer) {
                        mChildContainers.add((DBContainer<?>) container);
                    }
                }
            }
        }
    }

    @Override
    public void bindView(DBRootView parentView) {
        if (id != DBConstants.DEFAULT_ID_VIEW && null != parentView.getViewById(id)) {
            mNativeView = (V) parentView.getViewById(id);
            if (null != mNativeView) {
                // 绑定视图属性
                onAttributesBind(mNativeView, getAttrs());
            }
        } else {
            mNativeView = onCreateView(); // 回调子类View实现
            if (null != mNativeView) {
                // id
                String rawId = getAttrs().get("id");
                if (null != rawId) {
                    id = Integer.parseInt(rawId);
                    mNativeView.setId(id);
                }
                // layout 相关属性
                parseLayoutAttr(getAttrs());
                // 绑定视图属性
                onAttributesBind(mNativeView, getAttrs());
                // 绑定视图回调事件
                if (mCallbacks.size() > 0) {
                    onCallbackBind(mNativeView, mCallbacks);
                }
                // 绑定子视图
                if (mChildContainers.size() > 0) {
                    onChildrenBind(mNativeView, getAttrs(), mChildContainers);
                }
                // 添加到父容器
                setPadding();
                parentView.addView(mNativeView, getLayoutParams());
            } else {
                DBLogger.e(mDBContext, "[onCreateView] should not return null->" + this);
            }
        }
    }

    protected void onChildrenBind(V selfView, Map<String, String> attrs, List<DBContainer<?>> children) {
    }

    @Override
    protected void onAttributesBind(V selfView, final Map<String, String> attrs) {
        super.onAttributesBind(selfView, attrs);

        chainStyle = attrs.get("chainStyle");
        // visibleOn
        final String rawVisibleOn = attrs.get("visibleOn");
        boolean visibleOn;
        if (null == rawVisibleOn) {
            visibleOn = true;
        } else {
            visibleOn = getBoolean(rawVisibleOn);
        }
        if (visibleOn) {
            mNativeView.setVisibility(View.VISIBLE);
        } else {
            mNativeView.setVisibility(View.INVISIBLE);
        }
        if (null != rawVisibleOn) {
            mDBContext.observeDataPool(new DBData.IDataObserver() {
                @Override
                public void onDataChanged(String key) {
                    DBLogger.d(mDBContext, "key: " + key);
                    if (null != mNativeView) {
                        mNativeView.setVisibility(getBoolean(rawVisibleOn) ? View.VISIBLE : View.INVISIBLE);
                    }
                }

                @Override
                public String getKey() {
                    return attrs.get("visibleOn");
                }
            });
        }
        // changeOn
        String changeOn = attrs.get("changeOn");
        if (null != changeOn) {
            String[] keys = changeOn.split("\\|");
            for (final String key : keys) {
                onDataChanged(mNativeView, key, attrs);
            }
        }
    }

    protected void onDataChanged(final V selfView, final String key, final Map<String, String> attrs) {
    }

    @CallSuper
    protected void onCallbackBind(final V selfView, List<DBCallback> callbacks) {
        for (final DBCallback callback : callbacks) {
            if ("onClick".equals(callback.getTagName())) {
                selfView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        List<DBAction> actions = callback.getActionNodes();
                        for (DBAction action : actions) {
                            action.invoke();
                        }
                    }
                });
            }
        }
    }

    protected void doCallback(String callbackTag, List<DBCallback> callbacks) {
        for (DBCallback callback : callbacks) {
            if (callbackTag.equals(callback.getTagName())) {
                for (IDBAction action : callback.getActionNodes()) {
                    action.invoke();
                }
                break;
            }
        }
    }
}
