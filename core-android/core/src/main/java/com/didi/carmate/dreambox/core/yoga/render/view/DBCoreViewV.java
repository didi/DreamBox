package com.didi.carmate.dreambox.core.yoga.render.view;

import android.view.View;
import android.view.ViewGroup;
import android.widget.ScrollView;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBTemplate;
import com.didi.carmate.dreambox.core.base.IDBCoreView;
import com.didi.carmate.dreambox.core.bridge.IDBEventReceiver;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/5/8
 */
public class DBCoreViewV extends ScrollView implements IDBCoreView {
    private final DBContext mDBContext;

    public DBCoreViewV(DBContext dbContext, DBYogaView dbRootView) {
        super(dbContext.getContext());
        mDBContext = dbContext;
        init(dbRootView);
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

    private void init(DBYogaView rootView) {
        ViewGroup.LayoutParams lp = rootView.getLayoutParams();
        if (null == lp) {
            lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        }
        addView(rootView, lp);
    }
}
