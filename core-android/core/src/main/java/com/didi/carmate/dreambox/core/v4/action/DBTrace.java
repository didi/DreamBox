package com.didi.carmate.dreambox.core.v4.action;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBModel;
import com.didi.carmate.dreambox.core.v4.base.IDBNode;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.didi.carmate.dreambox.wrapper.v4.Wrapper;
import com.didi.carmate.dreambox.wrapper.v4.inner.WrapperTrace;

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
        doInvoke(attrs, null);
    }

    @Override
    public void doInvoke(Map<String, String> attrs, DBModel model) {
        String key = attrs.get("key");

        WrapperTrace trace = Wrapper.get(mDBContext.getAccessKey()).trace();
        WrapperTrace.TraceAdder traceAdder = trace.addTrace(key);
        // 多个attr,碰撞为数组
        List<DBTraceAttrItem> attrItems = traceAttr.getAttrItems();
        if (attrItems.size() > 0) {
            for (int i = 0; i < attrItems.size(); i++) {
                DBTraceAttrItem attrItem = attrItems.get(i);
                attrItem.doInvoke(model);
                traceAdder.add(attrItem.getKey(), attrItem.getValue());
            }
        } else { // 单个attr
            traceAttr.doInvoke(model);
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
