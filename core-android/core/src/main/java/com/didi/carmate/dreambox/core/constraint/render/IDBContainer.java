package com.didi.carmate.dreambox.core.constraint.render;

import com.didi.carmate.dreambox.core.constraint.render.view.DBConstraintView;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public interface IDBContainer<V extends DBConstraintView> extends IDBRender {
    /**
     * 执行View对象的布局和渲染
     */
    V onCreateView();

    /**
     * 容器类对象渲染完成后调用
     */
    void renderFinish();
}
