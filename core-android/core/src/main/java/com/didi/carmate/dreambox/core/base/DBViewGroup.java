package com.didi.carmate.dreambox.core.base;

import com.didi.carmate.dreambox.core.render.IDBRender;
import com.didi.carmate.dreambox.core.render.view.DBRootView;
import com.didi.carmate.dreambox.core.utils.DBLogger;

import java.util.List;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public abstract class DBViewGroup<V extends DBRootView> extends DBContainer<V> {
    public DBViewGroup(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void bindView(DBRootView parentView) {
        if (id != DBConstants.DEFAULT_ID_VIEW && null != parentView.getViewById(id)) {
            mNativeView = parentView.getViewById(id);
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
                parseLayoutAttr(getAttrs());
                // 绑定视图属性
                onAttributesBind(getAttrs());
                // 添加到父容器
                setPadding();
                parentView.addView(mNativeView, getLayoutParams());
            } else {
                DBLogger.e(mDBContext, "[onCreateView] should not return null->" + this);
            }
        }

        // 处理子View
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBRender) {
                ((IDBRender) child).bindView((DBRootView) mNativeView);
            }
        }
    }
}