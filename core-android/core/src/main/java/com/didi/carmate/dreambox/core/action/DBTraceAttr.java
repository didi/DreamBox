package com.didi.carmate.dreambox.core.action;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBNode;
import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.base.INodeCreator;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/10/26
 */
public class DBTraceAttr extends DBNode {
    private Map<String, String> attrs;
    // 单个attr时
    private final DBTraceAttrItem attrItem;
    // 多个attr发生碰撞时，生成attr数组
    private final List<DBTraceAttrItem> attrItems = new ArrayList<>();

    public DBTraceAttr(DBContext dbContext) {
        super(dbContext);

        attrItem = new DBTraceAttrItem(dbContext);
    }

    @Override
    protected void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        this.attrs = attrs;
    }

    @Override
    protected void onParserNode() {
        super.onParserNode();

        List<IDBNode> children = getChildren();
        for (IDBNode child : children) {
            if (child instanceof DBTraceAttrItem) {
                attrItems.add((DBTraceAttrItem) child);
            }
        }
    }

    public void doInvoke() {
        attrItem.setKey(attrs.get("key"));
        attrItem.setValue(getString(attrs.get("value")));
    }

    public List<DBTraceAttrItem> getAttrItems() {
        return attrItems;
    }

    public DBTraceAttrItem getAttrItem() {
        return attrItem;
    }

    public static String getNodeTag() {
        return "attr";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBTraceAttr createNode(DBContext dbContext) {
            return new DBTraceAttr(dbContext);
        }
    }
}
