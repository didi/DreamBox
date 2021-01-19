package com.didi.carmate.dreambox.core.v4.action;

import android.app.Activity;
import android.content.Context;

import com.didi.carmate.dreambox.core.v4.base.DBAction;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBClosePage extends DBAction {
    private DBClosePage(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        Context context = mDBContext.getContext();
        if (context instanceof Activity) {
            ((Activity) context).finish();
        }
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBClosePage createNode(DBContext dbContext) {
            return new DBClosePage(dbContext);
        }
    }

    public static String getNodeTag() {
        return "closePage";
    }
}