package com.didi.carmate.dreambox.core.base;

import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.action.IDBAction;
import com.didi.carmate.dreambox.core.data.DBData;
import com.didi.carmate.dreambox.core.render.DBChildren;
import com.didi.carmate.dreambox.core.utils.DBLogger;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public abstract class DBBaseView<V extends View> extends DBAbsView<V> {
    //    private String backgroundUrl;

    // View callback节点集合
    private final List<DBCallback> mCallbacks = new ArrayList<>();
    private final List<DBContainer<ViewGroup>> mChildContainers = new ArrayList<>();

    protected DBBaseView(DBContext dbContext) {
        super(dbContext);
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
                        mChildContainers.add((DBContainer<ViewGroup>) container);
                    }
                }
            }
        }
    }

    /**
     * 待改进，目前list vh里的view节点需要id属性，否则会重复创建对象
     */
    @Override
    public void bindView(ViewGroup parentView, NODE_TYPE nodeType, boolean bindAttrOnly) {
        if (id != DBConstants.DEFAULT_ID_VIEW && null != parentView && null != parentView.findViewById(id)) {
            mNativeView = parentView.findViewById(id);
            doBind(mNativeView, bindAttrOnly);
        } else {
            mNativeView = onCreateView(); // 回调子类View实现
            doBind(mNativeView, bindAttrOnly);
            addToParent(mNativeView, parentView);
        }
    }

    private void doBind(View nativeView, boolean bindAttrOnly) {
        if (bindAttrOnly) {
            onAttributesBind(getAttrs());
        } else {
            // id
            String rawId = getAttrs().get("id");
            if (null != rawId) {
                id = Integer.parseInt(rawId);
                nativeView.setId(id);
            }
            // layout 相关属性
            onParseLayoutAttr(getAttrs());
            // 绑定视图属性
            onAttributesBind(getAttrs());
            // 绑定视图回调事件
            if (mCallbacks.size() > 0) {
                onCallbackBind(mCallbacks);
            }
            // 绑定子视图
            if (mChildContainers.size() > 0) {
                onChildrenBind(getAttrs(), mChildContainers);
            }
        }
    }

    private void addToParent(View nativeView, ViewGroup container) {
        // DBLView里根节点调用bindView时container传null
        // 适配List和Flow场景，native view 已经在adapter里创建好，且无需执行添加操作
        if (null != container) {
            ViewGroup.MarginLayoutParams marginLayoutParams;
            if (container instanceof LinearLayout) {
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(width, height);
                layoutParams.gravity = layoutGravity;
                marginLayoutParams = layoutParams;
                container.addView(nativeView, layoutParams);
            } else if (container instanceof FrameLayout) {
                FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(width, height);
                layoutParams.gravity = layoutGravity;
                marginLayoutParams = layoutParams;
                container.addView(nativeView, layoutParams);
            } else {
                ViewGroup.MarginLayoutParams layoutParams = new ViewGroup.MarginLayoutParams(width, height);
                marginLayoutParams = layoutParams;
                container.addView(nativeView, layoutParams);
            }
            if (margin > 0) {
                marginLayoutParams.setMargins(margin, margin, margin, margin);
            } else {
                marginLayoutParams.setMargins(marginLeft, marginTop, marginRight, marginBottom);
            }
            onViewAdded(container);
        }
    }

    protected void onChildrenBind(Map<String, String> attrs, List<DBContainer<ViewGroup>> children) {
    }

    @Override
    protected void onAttributesBind(final Map<String, String> attrs) {
        super.onAttributesBind(attrs);

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
                onDataChanged(key, attrs);
            }
        }
    }

    protected void onDataChanged(final String key, final Map<String, String> attrs) {
    }

    @CallSuper
    protected void onCallbackBind(List<DBCallback> callbacks) {
        for (final DBCallback callback : callbacks) {
            if ("onClick".equals(callback.getTagName())) {
                mNativeView.setOnClickListener(new View.OnClickListener() {
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
