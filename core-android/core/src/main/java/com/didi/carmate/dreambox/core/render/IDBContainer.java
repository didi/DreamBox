package com.didi.carmate.dreambox.core.render;

import com.didi.carmate.dreambox.core.render.view.DBRootView;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public interface IDBContainer<V extends DBRootView> extends IDBRender {
    /**
     * 执行View对象的布局和渲染
     */
    V onCreateView();

    /**
     * 容器类对象渲染完成后调用
     */
    void renderFinish();
}
