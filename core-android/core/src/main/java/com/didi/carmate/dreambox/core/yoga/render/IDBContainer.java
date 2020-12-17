package com.didi.carmate.dreambox.core.yoga.render;

import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public interface IDBContainer<V extends DBYogaView> extends IDBYoga {
    /**
     * 执行View对象的布局和渲染
     */
    V onCreateView();

    /**
     * 容器类对象渲染完成后调用
     */
    void renderFinish();
}
