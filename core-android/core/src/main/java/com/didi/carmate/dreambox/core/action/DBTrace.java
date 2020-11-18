package com.didi.carmate.dreambox.core.action;

import com.didi.carmate.dreambox.core.base.DBAction;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.wrapper.Wrapper;
import com.didi.carmate.dreambox.wrapper.inner.WrapperTrace;

import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBTrace extends DBAction {
    private DBTraceAttr traceAttr;

    private DBTrace(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void onParserNode() {
        super.onParserNode();

        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof DBTraceAttr) {
                traceAttr = (DBTraceAttr) child;
                break;
            }
        }
    }

    @Override
    public void doInvoke(Map<String, String> attrs) {
        String key = attrs.get("key");

        WrapperTrace trace = Wrapper.get(mDBContext.getAccessKey()).trace();
        WrapperTrace.TraceAdder traceAdder = trace.addTrace(key);
        // 多个attr,碰撞为数组
        List<DBTraceAttrItem> attrItems = traceAttr.getAttrItems();
        if (attrItems.size() > 0) {
            for (int i = 0; i < attrItems.size(); i++) {
                DBTraceAttrItem attrItem = attrItems.get(i);
                attrItem.setData(getData()); // 将数据节点透传给子节点
                attrItem.doInvoke();
                traceAdder.add(attrItem.getKey(), attrItem.getValue());
            }
        } else { // 单个attr
            traceAttr.doInvoke();
            DBTraceAttrItem attrItem = traceAttr.getAttrItem();
            traceAdder.add(attrItem.getKey(), attrItem.getValue());
        }
        traceAdder.report();
    }

    public static String getNodeTag() {
        return "trace";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBTrace createNode(DBContext dbContext) {
            return new DBTrace(dbContext);
        }
    }
}
