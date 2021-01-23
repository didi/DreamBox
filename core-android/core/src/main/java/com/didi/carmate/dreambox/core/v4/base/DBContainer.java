package com.didi.carmate.dreambox.core.v4.base;

import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.v4.R;
import com.didi.carmate.dreambox.core.v4.render.IDBContainer;
import com.didi.carmate.dreambox.core.v4.render.IDBRender;
import com.didi.carmate.dreambox.core.v4.utils.DBLogger;
import com.facebook.yoga.YogaDisplay;
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
        if (id != DBConstants.DEFAULT_ID_VIEW && null != container && null != container.findViewById(id)) {
            mNativeView = container.findViewById(id);
            mNativeView.setTag(R.id.tag_key_item_data, data);
            mViews.put(position, mNativeView);

            doBind(mNativeView, bindAttrOnly, position);
        } else if (nodeType == NODE_TYPE.NODE_TYPE_NORMAL) {
            mNativeView = onCreateView(); // 回调子类View实现
            mNativeView.setTag(R.id.tag_key_item_data, data);
            mViews.put(position, mNativeView);

            doBind(mNativeView, bindAttrOnly, position);
            addToParent(mNativeView, container);
        } else if (nodeType == NODE_TYPE.NODE_TYPE_ADAPTER) {
            mNativeView = container; // 将每次的view对象赋值给容器节点，容器节点在adapter模式下公用的
            mNativeView.setTag(R.id.tag_key_item_data, data);
            mViews.put(position, mNativeView);

            doBind(mNativeView, bindAttrOnly, position);
            ViewGroup.LayoutParams layoutParams = mNativeView.getLayoutParams();
            layoutParams.width = width;
            layoutParams.height = height;
            mNativeView.setLayoutParams(layoutParams);
        } else if (nodeType == NODE_TYPE.NODE_TYPE_ROOT) {
            mNativeView = onCreateView();
            mNativeView.setId(DBConstants.DEFAULT_ID_ROOT);
            mNativeView.setTag(R.id.tag_key_item_data, data);
            mViews.put(position, mNativeView);

            doBind(mNativeView, bindAttrOnly, position);
            // 根容器宽高DSL里定义的优先
            mNativeView.setLayoutParams(new ViewGroup.LayoutParams(width, height));
        } else {
            DBLogger.e(mDBContext, "DBContainer::bindView, should not go here!");
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

    private void doBind(View nativeView, boolean bindAttrOnly, int position) {
        if (!bindAttrOnly) {
            // id
            String rawId = getAttrs().get(DBConstants.UI_ID);
            if (null != rawId) {
                id = Integer.parseInt(rawId);
                nativeView.setId(id);
            }
            // layout 相关属性
            onParseLayoutAttr(getAttrs());
        }
        // 绑定视图属性
        onAttributesBind(getAttrs());
        // 绑定视图回调事件
        if (mCallbacks.size() > 0) {
            onCallbackBind(mCallbacks, position);
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
                if (nativeView instanceof YogaLayout) {
                    if (nativeView.getVisibility() == View.GONE) {
                        ((YogaLayout) nativeView).getYogaNode().setDisplay(YogaDisplay.NONE);
                    } else {
                        ((YogaLayout) nativeView).getYogaNode().setDisplay(YogaDisplay.FLEX);
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

    @Override
    protected void onAttributesBind(final Map<String, String> attrs) {
        super.onAttributesBind(attrs);
        if (padding > 0) {
            mNativeView.setPadding(padding, padding, padding, padding);
        } else {
            mNativeView.setPadding(paddingLeft, paddingTop, paddingRight, paddingBottom);
        }
    }

    @CallSuper
    protected void onCallbackBind(List<DBCallback> callbacks, final int position) {
        for (final DBCallback callback : callbacks) {
            if ("onClick".equals(callback.getTagName())) {
                mNativeView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        List<DBAction> actions = callback.getActionNodes();
                        for (DBAction action : actions) {
                            action.invoke(mViews.get(position));
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
