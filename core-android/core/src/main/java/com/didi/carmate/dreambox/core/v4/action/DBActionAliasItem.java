package com.didi.carmate.dreambox.core.v4.action;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBNode;
import com.didi.carmate.dreambox.core.v4.base.IDBNode;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * author: chenjing
 * date: 2020/10/26
 */
public class DBActionAliasItem extends DBNode {
    private Map<String, String> attrs;
    private String id;
    private final List<DBAction> mActionNodes = new ArrayList<>();

    public DBActionAliasItem(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        this.attrs = attrs;
        id = attrs.get("id");
    }

    @Override
    protected void onParserNode() {
        super.onParserNode();

        List<IDBNode> children = getChildren();
        if (children.size() > 0) {
            DBActions actions = (DBActions) children.get(0);
            children = actions.getChildren();
            for (IDBNode item : children) {
                if (item instanceof DBAction) {
                    mActionNodes.add((DBAction) item);
                }
            }
        }
    }

    public void doInvoke() {
        JsonObject srcJsonObject = getJsonObject(attrs.get("src"));
        // invoke 的[src]属性拥有更高的优先级，key相同时覆盖此节点数据
        if (null != srcJsonObject && null != getData()) {
            setActionsData(combineJson(srcJsonObject, getData()));
        } else if (null != srcJsonObject) {
            setActionsData(srcJsonObject);
        }
    }

    public void setAttrs(Map<String, String> attrs) {
        this.attrs = attrs;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void putAction(DBAction action) {
        mActionNodes.add(action);
    }

    public String getId() {
        return id;
    }

    public List<DBAction> getActionNodes() {
        return mActionNodes;
    }

    private void setActionsData(JsonObject data) {
        for (DBAction action : mActionNodes) {
            action.setData(data); // 将invoke[src]设置到action
        }
    }

    /**
     * 合并两个JsonObject对象，如果有相同的key，addedObj 优先级高于 srcObj
     *
     * @param srcObj   原json对象
     * @param addedObj 待合并json对象
     */
    private static JsonObject combineJson(JsonObject srcObj, JsonObject addedObj) {
        Set<String> addObjKeys = addedObj.keySet();
        for (String key : addObjKeys) {
            srcObj.add(key, addedObj.get(key));
        }
        return srcObj;
    }
}
