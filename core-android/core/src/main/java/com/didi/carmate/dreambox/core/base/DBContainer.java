package com.didi.carmate.dreambox.core.base;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.render.IDBContainer;
import com.didi.carmate.dreambox.core.render.view.DBRootView;

import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public abstract class DBContainer<V extends DBRootView> extends DBAbsView<V> implements IDBContainer<V> {
    private Map<String, String> parentAttrs;

    public DBContainer(DBContext dbContext) {
        super(dbContext);
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

        // 目前不需要chain完整能力，以下代码暂时不需要
//        if (null != mNativeView) {
//            mNativeView.onRenderFinish(this);
//            DBLogger.d(mDBContext, "not null class: " + this);
//        } else {
//            DBLogger.d(mDBContext, "null class: " + this);
//        }
    }

    public Map<String, String> getParentAttrs() {
        return parentAttrs;
    }

    public void setParentAttrs(Map<String, String> parentAttrs) {
        this.parentAttrs = parentAttrs;
    }
}
