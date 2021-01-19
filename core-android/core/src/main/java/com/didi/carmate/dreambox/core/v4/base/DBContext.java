package com.didi.carmate.dreambox.core.v4.base;

import android.app.Application;
import android.content.Context;

import com.didi.carmate.dreambox.core.v4.action.DBActionAliasItem;
import com.didi.carmate.dreambox.core.v4.bridge.DBBridgeHandler;
import com.didi.carmate.dreambox.core.v4.data.DBData;
import com.didi.carmate.dreambox.core.v4.data.DBDataPool;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/11
 */
public class DBContext {
    private Application mApplication;
    private Context mCurrentContext;
    private DBTemplate mDBTemplate;
    private DBDataPool mDataPool;
    private final Map<String, Integer> mViewIdMap = new HashMap<>();
    private final DBBridgeHandler mBridgeHandler;
    private final String mAccessKey;
    private final String mTemplateId;

    public DBContext(Application application, String accessKey, String templateId) {
        mApplication = application;
        mAccessKey = accessKey;
        mTemplateId = templateId;
        mDataPool = new DBDataPool();
        mBridgeHandler = new DBBridgeHandler(this);
    }

    public String getAccessKey() {
        return mAccessKey;
    }

    public String getTemplateId() {
        return mTemplateId;
    }

    public Map<String, Integer> getViewIdMap() {
        return mViewIdMap;
    }

    public void putViewId(String idString, Integer idInt) {
        mViewIdMap.put(idString, idInt);
    }

    public void setCurrentContext(Context currentContext) {
        mCurrentContext = currentContext;
    }

    public void setExtJsonObject(JsonObject extJsonObject) {
        if (null != mDataPool && null != extJsonObject) {
            mDataPool.putData(DBConstants.DATA_EXT_PREFIX, extJsonObject);
        }
    }

    public void setExtJsonObject(String key, JsonObject extJsonObject) {
        if (null != mDataPool && null != extJsonObject) {
            mDataPool.putData(key, extJsonObject);
        }
    }

    public List<DBActionAliasItem> getActionAliasItems() {
        return mDBTemplate.getActionAliasItems();
    }

    public void setDBTemplate(DBTemplate template) {
        this.mDBTemplate = template;
    }

    public DBTemplate getDBTemplate() {
        return mDBTemplate;
    }

    // ------------- meta pool -------------
    public void putStringValue(String key, String value) {
        if (null != mDataPool) {
            mDataPool.putData(key, value);
        }
    }

    public String getStringValue(String key) {
        if (null != mDataPool) {
            return mDataPool.getString(key);
        }
        return "";
    }

    public void putBooleanValue(String key, boolean value) {
        if (null != mDataPool) {
            mDataPool.putData(key, value);
        }
    }

    public boolean getBooleanValue(String key) {
        if (null != mDataPool && null != key) {
            return mDataPool.getBoolean(key);
        } else {
            return false;
        }
    }

    public void putIntValue(String key, int value) {
        if (null != mDataPool) {
            mDataPool.putData(key, value);
        }
    }

    public int getIntValue(String key) {
        if (null != mDataPool) {
            return mDataPool.getInt(key);
        }
        return -1;
    }

    public void putJsonValue(String key, JsonObject jsonObject) {
        if (null != mDataPool) {
            mDataPool.putData(key, jsonObject);
        }
    }

    public JsonObject getJsonValue(String key) {
        if (null != mDataPool) {
            return mDataPool.getDict(key);
        }
        return null;
    }

    public void putJsonArray(String key, JsonArray jsonArray) {
        if (null != mDataPool) {
            mDataPool.putData(key, jsonArray);
        }
    }

    public JsonArray getJsonArray(String key) {
        if (null != mDataPool) {
            return mDataPool.getDictArray(key);
        }
        return null;
    }

    public void changeStringValue(String key, String value) {
        if (null != mDataPool) {
            mDataPool.changeStringData(key, value);
        }
    }

    public void changeBooleanValue(String key, boolean value) {
        if (null != mDataPool) {
            mDataPool.changeBooleanData(key, value);
        }
    }

    public void changeIntValue(String key, int value) {
        if (null != mDataPool) {
            mDataPool.changeIntData(key, value);
        }
    }

    public void observeDataPool(DBData.IDataObserver observeData) {
        if (null != mDataPool) {
            mDataPool.observeDataPool(observeData);
        }
    }

    // ------------- meta pool -------------

    public Context getContext() {
        return null != mCurrentContext ? mCurrentContext : mApplication;
    }

    public Application getApplication() {
        return mApplication;
    }

    public DBBridgeHandler getBridgeHandler() {
        return mBridgeHandler;
    }

    public void release() {
        mApplication = null;
        mCurrentContext = null;
        mDBTemplate = null;
        if (null != mDataPool) {
            mDataPool.release();
            mDataPool = null;
        }
    }
}
