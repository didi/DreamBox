package com.didi.carmate.dreambox.core.constraint.render;

import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.constraint.render.view.DBConstraintView;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public interface IDBRender extends IDBNode {
    /**
     * 执行View对象的布局和渲染
     */
    void bindView(DBConstraintView parentView);
}
