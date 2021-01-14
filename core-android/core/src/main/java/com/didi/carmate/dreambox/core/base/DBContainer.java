package com.didi.carmate.dreambox.core.base;

import android.view.ViewGroup;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.render.IDBContainer;
import com.didi.carmate.dreambox.core.render.IDBRender;
import com.didi.carmate.dreambox.core.utils.DBLogger;

import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public abstract class DBContainer<V extends ViewGroup> extends DBAbsView<V> implements IDBContainer<V> {
    private Map<String, String> parentAttrs;

    public DBContainer(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void bindView(ViewGroup container) {
        bindView(container, false);
    }

    @Override
    public void bindView(ViewGroup container, boolean containerHasCreated) {
        if (id != DBConstants.DEFAULT_ID_VIEW && null != container && null != container.findViewById(id)) {
            mNativeView = container.findViewById(id);
            if (null != mNativeView) {
                // 绑定视图属性
                onAttributesBind(getAttrs());
            }
        } else {
            if (!containerHasCreated) {
                mNativeView = onCreateView(); // 回调子类View实现
            } else {
                // 适配List和Flow场景，native view 已经在adapter里创建好，无需重复创建
                mNativeView = container;
            }
            if (null != mNativeView) {
                // id
                String rawId = getAttrs().get("id");
                if (null != rawId) {
                    id = Integer.parseInt(rawId);
                    mNativeView.setId(id);
                }
                // layout 相关属性
                onParseLayoutAttr(getAttrs());
                // 绑定视图属性
                onAttributesBind(getAttrs());
                // 添加到父容器
                mNativeView.setLayoutParams(new ViewGroup.LayoutParams(width, height));
                // DBLView里根节点调用bindView时container传null
                // 适配List和Flow场景，native view 已经在adapter里创建好，且无需执行添加操作
                if (null != container && !containerHasCreated) {
                    container.addView(mNativeView);
                    onViewAdded(container);
                }
            } else {
                DBLogger.e(mDBContext, "[onCreateView] should not return null->" + this);
            }
        }

        // 递归子节点的bindView
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBRender) {
                ((IDBRender) child).bindView((ViewGroup) mNativeView);
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
