package com.didi.carmate.dreambox.core.layout.render;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.IDBNode;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public interface IDBRender extends IDBNode {
    /**
     * 执行View对象的布局和渲染
     */
    void bindView(ViewGroup container);

    /**
     * Flow的List,等组件会在adapter里创建自己的根节点对象
     */
    void bindView(ViewGroup container, boolean containerHasCreated);
}
