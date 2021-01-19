package com.didi.carmate.dreambox.core.v4.base;

import com.didi.carmate.dreambox.core.v4.action.IDBAction;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;

import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public abstract class DBAction extends DBNode implements IDBAction {
    public DBAction(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void invoke() {
        Map<String, String> attrs = getAttrs();
        String dependOn = attrs.get("dependOn");

        if (DBUtils.isEmpty(dependOn)) {
            doInvoke(attrs);
        } else {
            String[] keys = dependOn.split(";");
            if (keys.length == 1 && getBoolean(keys[0])) {
                doInvoke(attrs);
            } else if (getBoolean(keys[0]) && getBoolean(keys[1])) {
                doInvoke(attrs);
            }
        }
    }

    protected void doCallback(String callbackTag, List<DBCallback> callbacks) {
        for (DBCallback callback : callbacks) {
            if (callbackTag.equals(callback.getTagName())) {
                for (IDBAction action : callback.getActionNodes()) {
                    action.invoke();
                }
                break;
            }
        }
    }

    protected abstract void doInvoke(Map<String, String> attrs);
}
