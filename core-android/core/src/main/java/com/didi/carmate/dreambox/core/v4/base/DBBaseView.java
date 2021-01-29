package com.didi.carmate.dreambox.core.v4.base;

import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.v4.action.IDBAction;
import com.didi.carmate.dreambox.core.v4.render.DBChildren;
import com.facebook.yoga.YogaDisplay;
import com.facebook.yoga.android.YogaLayout;
import com.google.gson.JsonObject;

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
    public void bindView(ViewGroup parentView, NODE_TYPE nodeType, boolean bindAttrOnly,
                         JsonObject data, int position) {
        DBModel model = getModel(position);

        // 取当前ViewID
        int _id = DBConstants.DEFAULT_ID_VIEW;
        String rawId = getAttrs().get(DBConstants.UI_ID);
        if (null != rawId) {
            _id = Integer.parseInt(rawId);
        }

        // 判断是否可以复用
        if (_id != DBConstants.DEFAULT_ID_VIEW && null != parentView && null != parentView.findViewById(_id)) {
            mNativeView = parentView.findViewById(_id);
            model.setView(mNativeView);
            model.setData(data);

            doBind(model, bindAttrOnly);
            if ((parentView instanceof YogaLayout)) {
                ((YogaLayout) parentView).invalidate(mNativeView);
            }
        } else {
            mNativeView = onCreateView(); // 回调子类View实现
            model.setId(bindId(mNativeView));
            model.setView(mNativeView);
            model.setData(data);

            doBind(model, bindAttrOnly);
            addToParent(mNativeView, parentView);
        }
    }

    private DBModel getModel(int position) {
        DBModel model = mModels.get(position);
        if (null == model) {
            model = new DBModel();
            mModels.put(position, model);
        }
        return model;
    }

    private int bindId(View nativeView) {
        // id
        String rawId = getAttrs().get(DBConstants.UI_ID);
        if (null != rawId) {
            id = Integer.parseInt(rawId);
            nativeView.setId(id);
        }
        return id;
    }

    private void doBind(DBModel model, boolean bindAttrOnly) {
        if (!bindAttrOnly) {
            // layout 相关属性
            onParseLayoutAttr(getAttrs());
        }
        // 绑定视图属性
        onAttributesBind(getAttrs(), model);
        // 绑定视图回调事件
        if (mCallbacks.size() > 0) {
            onCallbackBind(mCallbacks, model);
        }
        // 绑定子视图
        if (mChildContainers.size() > 0) {
            onChildrenBind(getAttrs(), mChildContainers);
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

                // GONE处理
                if (container instanceof YogaLayout) {
                    if (nativeView.getVisibility() == View.GONE) {
                        ((YogaLayout) container).getYogaNodeForView(nativeView).setDisplay(YogaDisplay.NONE);
                    } else {
                        ((YogaLayout) container).getYogaNodeForView(nativeView).setDisplay(YogaDisplay.FLEX);
                    }
                }
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
    protected void onAttributesBind(final Map<String, String> attrs, DBModel model) {
        super.onAttributesBind(attrs, model);

        // changeOn
        String changeOn = attrs.get("changeOn");
        if (null != changeOn) {
            String[] keys = changeOn.split("\\|");
            for (final String key : keys) {
                onDataChanged(key, attrs, model);
            }
        }
    }

    protected void onDataChanged(final String key, final Map<String, String> attrs, DBModel model) {
    }

    @CallSuper
    protected void onCallbackBind(List<DBCallback> callbacks, final DBModel model) {
        for (final DBCallback callback : callbacks) {
            if ("onClick".equals(callback.getTagName())) {
                mNativeView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        List<DBAction> actions = callback.getActionNodes();
                        for (DBAction action : actions) {
                            action.invoke(model);
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
