package com.didi.carmate.dreambox.core.action;

import com.didi.carmate.dreambox.core.base.DBAction;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.google.gson.JsonObject;

import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBInvoke extends DBAction {
    private DBActionAliasItem aliasItem;
    private String aliasId;

    private DBInvoke(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        aliasId = attrs.get("alias");
    }

    @Override
    protected void onAttributesBind(Map<String, String> attrs) {
        super.onAttributesBind(attrs);

        List<DBActionAliasItem> actionAliasItems = mDBContext.getActionAliasItems();
        for (DBActionAliasItem item : actionAliasItems) {
            if (aliasId.equals(item.getId())) {
                aliasItem = item;
                break;
            }
        }
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        JsonObject jsonObject = getJsonObject(attrs.get("src"));

        if (null != aliasItem) {
            aliasItem.setData(jsonObject); // 将数据源给到子元素
            aliasItem.doInvoke(); // 实时获取子元素自身的数据，同时和上面的数据源做merge
        }
    }

    public DBActionAliasItem getAliasItem() {
        return aliasItem;
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBInvoke createNode(DBContext dbContext) {
            return new DBInvoke(dbContext);
        }
    }

    public static String getNodeTag() {
        return "invoke";
    }
}