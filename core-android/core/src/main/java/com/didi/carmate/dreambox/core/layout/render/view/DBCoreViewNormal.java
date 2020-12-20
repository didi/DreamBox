package com.didi.carmate.dreambox.core.layout.render.view;

import android.view.View;
import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBTemplate;
import com.didi.carmate.dreambox.core.base.IDBCoreView;
import com.didi.carmate.dreambox.core.bridge.IDBEventReceiver;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/5/8
 */
public class DBCoreViewNormal implements IDBCoreView {
    private final DBContext mDBContext;
    private final ViewGroup mRootView;

    public DBCoreViewNormal(DBContext dbContext, ViewGroup rootView) {
        mDBContext = dbContext;
        mRootView = rootView;
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
            mRootView.removeAllViews();
            dbTemplate.invalidate();
        }
    }

    @Override
    public View getView() {
        return mRootView;
    }

    @Override
    public View getRootView() {
        return mRootView.getRootView();
    }

    @Override
    public void sendEvent(String eid, String msgTo) {
        mDBContext.getBridgeHandler().nativeInvokeDb(eid, msgTo);
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
