package com.didi.carmate.dreambox.core.yoga.base;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.utils.DBLogger;
import com.didi.carmate.dreambox.core.yoga.render.IDBYoga;
import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;

import java.util.List;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public abstract class DBViewGroup<V extends DBYogaView> extends DBContainer<V> {
    public DBViewGroup(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void bindView(DBYogaView parentView) {
        if (id != DBConstants.DEFAULT_ID_VIEW && null != parentView.findViewById(id)) {
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
                parseLayoutAttr(getAttrs());
                // 绑定视图属性
                onAttributesBind(getAttrs());
                // 添加到父容器
                setMargin(parentView);
                setPadding(parentView);
                parentView.addView(mNativeView, new ViewGroup.LayoutParams(width, height));
            } else {
                DBLogger.e(mDBContext, "[onCreateView] should not return null->" + this);
            }
        }

        // 处理子View
        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof IDBYoga) {
                ((IDBYoga) child).bindView((DBYogaView) mNativeView);
            }
        }
    }
}