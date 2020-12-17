package com.didi.carmate.dreambox.core.constraint.render.view;

import android.view.View;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBTemplate;
import com.didi.carmate.dreambox.core.base.IDBCoreView;
import com.didi.carmate.dreambox.core.bridge.IDBEventReceiver;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/5/8
 */
public class DreamBoxCoreView extends DBConstraintView implements IDBCoreView {
    DBContext mDBContext;

    public DreamBoxCoreView(DBContext dbContext) {
        super(dbContext, null);
        mDBContext = dbContext;
    }

    @Override
    public void putExtProperty(String key, String value) {
        mDBContext.putStringValue(key, value);
    }

    @Override
    public void putExtProperty(String key, int value) {
        mDBContext.putIntValue(key, value);
    }

    @Override
    public void putExtProperty(String key, boolean value) {
        mDBContext.putBooleanValue(key, value);
    }

    @Override
    public void setExtData(JsonObject extJsonObject) {
        mDBContext.setExtJsonObject(extJsonObject);
    }

    @Override
    public void requestRender() {
        DBTemplate dbTemplate = mDBContext.getDBTemplate();
        if (null != dbTemplate) {
            removeAllViews();
            dbTemplate.invalidate();
        }
    }

    @Override
    public View getView() {
        return this;
    }

    @Override
    public void sendEvent(String eid, String eventData) {
        mDBContext.getBridgeHandler().nativeInvokeDb(eid, eventData);
    }

    @Override
    public void registerEventReceiver(String eid, IDBEventReceiver eventReceiver) {
        mDBContext.getBridgeHandler().registerEventReceiver(eid, eventReceiver);
    }

    @Override
    public void unRegisterEventReceiver(String eid) {
        mDBContext.getBridgeHandler().unRegisterEventReceiver(eid);
    }
}
