package com.didi.carmate.dreambox.core.yoga.render;

import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public interface IDBYoga extends IDBNode {
    /**
     * 执行View对象的布局和渲染
     */
    void bindView(DBYogaView parentView);
}
