package com.didi.carmate.dreambox.core.v4.base;

import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.v4.render.IDBContainer;
import com.didi.carmate.dreambox.core.v4.render.IDBRender;
import com.facebook.yoga.android.YogaLayout;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public abstract class DBContainer<V extends ViewGroup> extends DBAbsView<V> implements IDBContainer<V> {
    private Map<String, String> parentAttrs;
    // View callback节点集合
    private final List<DBCallback> mCallbacks = new ArrayList<>();

    public DBContainer(DBContext dbContext) {
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
            }
        }
    }

    /**
     * 容器节点自身的 mNativeView 对象有3种情况
     * 1. 根节点 此种情况 container 参数为null，需要调用 onCreateView 来创建自己的 mNativeView
     * 2. Adapter节点，在 onCreateViewHolder 创建了跟容器，container 为创建的跟容器对象，不需要创建
     * 3. 作为普通节点，container 为当前对象的父容器，需要调用 onCreateView 创建自己的 mNativeView
     */

    @Override
    public void bindView(ViewGroup container, NODE_TYPE nodeType) {
        bindView(container, nodeType, false);
    }

    @Override
    public void bindView(ViewGroup container, NODE_TYPE nodeType, boolean bindAttrOnly) {
        bindView(container, nodeType, bindAttrOnly, null, -1);
    }

    /**
     * 待改进，目前list vh里的view节点需要id属性，否则会重复创建对象
     */
    @Override
    public void bindView(ViewGroup container, NODE_TYPE nodeType, boolean bindAttrOnly, JsonObject data, int position) {
        if (nodeType == NODE_TYPE.NODE_TYPE_ADAPTER) {
            mNativeView = container; // 将每次的view对象赋值给容器节点，容器节点在adapter模式下公用的
            DBModel model = getModel(position);
            model.setData(data);
            model.setView(mNativeView);

            doBind(model, bindAttrOnly);
            ViewGroup.LayoutParams layoutParams = mNativeView.getLayoutParams();
            if (layoutParams.width < 0) {
                layoutParams.width = width;
            }
            if (layoutParams.height < 0) {
                layoutParams.height = height;
            }
            mNativeView.setLayoutParams(layoutParams);
//            rebindAttributes(mNativeView, container);
        } else if (nodeType == NODE_TYPE.NODE_TYPE_NORMAL) {
            DBModel model = getModel(position);

            if (_id != DBConstants.DEFAULT_ID_VIEW && null != container && null != container.findViewById(_id)) {
                mNativeView = container.findViewById(_id);
                model.setView(mNativeView);
                model.setData(data);

                doBind(model, bindAttrOnly);
                rebindAttributes(mNativeView, container);
                setYogaDisplay(mNativeView, container);
                if ((container instanceof YogaLayout) && !(mNativeView instanceof YogaLayout)) {
                    ((YogaLayout) container).invalidate(mNativeView);
                }
            } else {
                mNativeView = onCreateView(); // 回调子类View实现
                mNativeView.setId(_id);
                model.setId(_id);
                model.setView(mNativeView);
                model.setData(data);

                doBind(model, bindAttrOnly);
                addToParent(mNativeView, container);
                rebindAttributes(mNativeView, container);
            }
        } else if (nodeType == NODE_TYPE.NODE_TYPE_ROOT) {
            if (null == mNativeView) {
                mNativeView = onCreateView();
                mNativeView.setId(DBConstants.DEFAULT_ID_ROOT);
            }
            DBModel model = getModel(position);
            model.setId(DBConstants.DEFAULT_ID_ROOT);
            model.setView(mNativeView);
            model.setData(data);

            doBind(model, bindAttrOnly);
//            // 根容器宽高DSL里定义的优先, 外出DreamBoxView是FrameLayout，所以使用FrameLayout.LayoutParams
//            FrameLayout.LayoutParams layoutParams;
//            if (null == mNativeView.getLayoutParams()) {
//                layoutParams = new FrameLayout.LayoutParams(width, height);
//            } else {
//                layoutParams = (FrameLayout.LayoutParams) mNativeView.getLayoutParams();
//            }
//            mNativeView.setLayoutParams(layoutParams);
            rebindAttributes(mNativeView, container);
        }

        // 递归子节点的bindView
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBRender) {
                ((IDBRender) child).bindView((ViewGroup) mNativeView, NODE_TYPE.NODE_TYPE_NORMAL, bindAttrOnly,
                        data, position);
            }
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

    @CallSuper
    @Override
    public void renderFinish() {
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBContainer) {
                ((IDBContainer<?>) child).renderFinish();
            }
        }
    }

    public Map<String, String> getParentAttrs() {
        return parentAttrs;
    }

    public void setParentAttrs(Map<String, String> parentAttrs) {
        this.parentAttrs = parentAttrs;
    }
}
