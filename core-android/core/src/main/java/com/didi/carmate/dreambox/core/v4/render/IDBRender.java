package com.didi.carmate.dreambox.core.v4.render;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.v4.base.IDBNode;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public interface IDBRender extends IDBNode {
    enum NODE_TYPE {
        NODE_TYPE_NORMAL(1),    // 容器节点作为普通节点
        NODE_TYPE_ROOT(2),      // 容器节点作为根节点(layout)
        NODE_TYPE_ADAPTER(3);   // 容器节点作为数据驱动节点(cell,list的header/footer/vh)

        int nodeType;

        NODE_TYPE(int nodeType) {
            this.nodeType = nodeType;
        }

        int getNodeType() {
            return nodeType;
        }
    }

    void bindView(ViewGroup container, NODE_TYPE nodeType);

    void bindView(ViewGroup container, NODE_TYPE nodeType, boolean bindAttrOnly);

    void bindView(ViewGroup container, NODE_TYPE nodeType, boolean bindAttrOnly, JsonObject data, int position);
}
