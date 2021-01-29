package com.didi.carmate.dreambox.core.v4.action;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBModel;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
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
    protected void onParserNodeFinished() {
        super.onParserNodeFinished();

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
        doInvoke(attrs, null);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs, DBModel model) {
        JsonObject jsonObject = getJsonObject(attrs.get("src"), model);

        if (null != aliasItem) {
            aliasItem.doInvoke(model, jsonObject); // 实时获取子元素自身的数据，同时和上面的数据源做merge
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