package com.airk.dreamhouse;

import android.view.View;

import com.airk.dreamhouse.demo.R;
import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBConstants;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.google.gson.JsonObject;

import java.util.List;
import java.util.Map;

public class CXAddCartAction extends DBAction {
    private CXAddCartAction(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs, View view, JsonObject data) {
        final List<JsonObject> array = getJsonObjectList(attrs.get("data"));
        final JsonObject obj = getJsonObject(attrs.get("data"), data);
        if (null != obj) {
            obj.toString();
        }
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public CXAddCartAction createNode(DBContext dbContext) {
            return new CXAddCartAction(dbContext);
        }
    }

    public static String getNodeTag() {
        return "addCartAction";
    }
}
