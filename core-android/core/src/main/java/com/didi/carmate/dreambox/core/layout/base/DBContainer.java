package com.didi.carmate.dreambox.core.layout.base;

import android.view.ViewGroup;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.layout.render.IDBContainer;
import com.didi.carmate.dreambox.core.layout.render.IDBRender;
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
    public void bindView(ViewGroup parentView) {
        if (id != DBConstants.DEFAULT_ID_VIEW && null != parentView && null != parentView.findViewById(id)) {
            mNativeView = parentView.findViewById(id);
            if (null != mNativeView) {
                // 绑定视图属性
                onAttributesBind(getAttrs());
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
                onParseLayoutAttr(getAttrs());
                // 绑定视图属性
                onAttributesBind(getAttrs());
                // 添加到父容器
                if (null != parentView) {
                    parentView.addView(mNativeView, new ViewGroup.LayoutParams(width, height));
                    onViewAdded(parentView);
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
