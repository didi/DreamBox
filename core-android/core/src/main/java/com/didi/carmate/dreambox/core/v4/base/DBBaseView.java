package com.didi.carmate.dreambox.core.v4.base;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.v4.action.IDBAction;
import com.didi.carmate.dreambox.core.v4.render.DBChildren;
import com.didi.carmate.dreambox.wrapper.v4.Wrapper;
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
        if (null == parentView) {
            Wrapper.get(mDBContext.getAccessKey()).log().e("parent is null!");
            return;
        }

        DBModel model = getModel(position);

        // 判断是否可以复用
        if (_id != DBConstants.DEFAULT_ID_VIEW && null != parentView.findViewById(_id)) {
            mNativeView = parentView.findViewById(_id);
            model.setView(mNativeView);
            model.setData(data);

            doBind(model, bindAttrOnly);
            rebindAttributes(nodeType, mNativeView, parentView);
            setYogaDisplay(mNativeView, parentView);
            if ((parentView instanceof YogaLayout)) {
                ((YogaLayout) parentView).invalidate(mNativeView);
            }
        } else {
            mNativeView = onCreateView(); // 回调子类View实现
            mNativeView.setId(_id);
            model.setId(_id);
            model.setView(mNativeView);
            model.setData(data);

            doBind(model, bindAttrOnly);
            // 绑定子视图
            if (mChildContainers.size() > 0) {
                onChildrenBind(getAttrs(), mChildContainers);
            }
            // 添加到父容器
            addToParent(mNativeView, parentView);
            rebindAttributes(nodeType, mNativeView, parentView);
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

    private void doBind(DBModel model, boolean bindAttrOnly) {
        if (!bindAttrOnly) {
            // layout 相关属性
            onParseLayoutAttr(getAttrs(), model);
        }
        // 绑定视图属性
        onAttributesBind(getAttrs(), model);
        // 绑定视图回调事件
        if (mCallbacks.size() > 0) {
            onCallbackBind(mCallbacks, model);
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
