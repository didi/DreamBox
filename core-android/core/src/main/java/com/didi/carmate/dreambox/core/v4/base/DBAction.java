package com.didi.carmate.dreambox.core.v4.base;

import android.view.View;

import com.didi.carmate.dreambox.core.v4.R;
import com.didi.carmate.dreambox.core.v4.action.IDBAction;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;
import com.google.gson.JsonObject;

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
    public void invoke(View view) {
        _invoke(view);
    }

    @Override
    public void invoke() {
        _invoke(null);
    }

    private void _invoke(View view) {
        Map<String, String> attrs = getAttrs();
        String dependOn = attrs.get("dependOn");

        if (DBUtils.isEmpty(dependOn)) {
            if (null == view) {
                doInvoke(attrs);
            } else {
                Object obj = view.getTag(R.id.tag_key_item_data);
                if (null != obj) {
                    doInvoke(attrs, view, (JsonObject) obj);
                } else {
                    doInvoke(attrs, view);
                }
            }
        } else {
            String[] keys = dependOn.split(";");
            if (keys.length == 1 && getBoolean(keys[0])) {
                if (null == view) {
                    doInvoke(attrs);
                } else {
                    Object obj = view.getTag(R.id.tag_key_item_data);
                    if (null != obj) {
                        doInvoke(attrs, view, (JsonObject) obj);
                    } else {
                        doInvoke(attrs, view);
                    }
                }
            } else if (getBoolean(keys[0]) && getBoolean(keys[1])) {
                if (null == view) {
                    doInvoke(attrs);
                } else {
                    Object obj = view.getTag(R.id.tag_key_item_data);
                    if (null != obj) {
                        doInvoke(attrs, view, (JsonObject) obj);
                    } else {
                        doInvoke(attrs, view);
                    }
                }
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

    protected void doInvoke(Map<String, String> attrs) {
    }

    protected void doInvoke(Map<String, String> attrs, View view) {
    }

    protected void doInvoke(Map<String, String> attrs, View view, JsonObject data) {
    }
}
