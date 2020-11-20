package com.didi.carmate.dreambox.core.data;

import com.didi.carmate.dreambox.core.base.DBTemplate;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBDataPool {
    private final IDBData<String> stringDataPool = new DBData<>(); // 字符串数据池
    private final IDBData<Integer> intDataPool = new DBData<>(); // int型数据池
    private final IDBData<Boolean> booleanDataPool = new DBData<>(); // 布尔型数据池
    private final IDBData<JsonObject> dictDataPool = new DBData<>(); // 字典类型数据池
    private final IDBData<JsonArray> dictArrayDataPool = new DBData<>(); // 字典数组数据池

    public void putData(DBTemplate template, String key, String value) {
        stringDataPool.addData(template, key, value);
    }

    public void putData(DBTemplate template, String key, int value) {
        intDataPool.addData(template, key, value);
    }

    public void putData(DBTemplate template, String key, boolean value) {
        booleanDataPool.addData(template, key, value);
    }

    public void putData(DBTemplate template, String key, JsonObject value) {
        dictDataPool.addData(template, key, value);
    }

    public void putData(DBTemplate template, String key, JsonArray value) {
        dictArrayDataPool.addData(template, key, value);
    }

    public String getString(DBTemplate template, String key) {
        String value = stringDataPool.getData(template, key);
        if (null == value) {
            return "";
        } else {
            return value;
        }
    }

    public int getInt(DBTemplate template, String key) {
        Integer value = intDataPool.getData(template, key);
        if (null == value) {
            return -1;
        } else {
            return value;
        }
    }

    public boolean getBoolean(DBTemplate template, String key) {
        Boolean value = booleanDataPool.getData(template, key);
        if (null == value) {
            return false;
        }
        return value;
    }

    public JsonObject getDict(DBTemplate template, String key) {
        return dictDataPool.getData(template, key);
    }

    public JsonArray getDictArray(DBTemplate template, String key) {
        return dictArrayDataPool.getData(template, key);
    }

    public void observeDataString(DBTemplate template, DBData.IDataObserver<String> observeData) {
        stringDataPool.observeData(template, observeData);
    }

    public void observeDataBoolean(DBTemplate template, DBData.IDataObserver<Boolean> observeData) {
        booleanDataPool.observeData(template, observeData);
    }

    public void observeDataInt(DBTemplate template, DBData.IDataObserver<Integer> observeData) {
        intDataPool.observeData(template, observeData);
    }

    public void observeDataJsonObject(DBTemplate template, DBData.IDataObserver<JsonObject> observeData) {
        dictDataPool.observeData(template, observeData);
    }

    public void observeDataJsonArray(DBTemplate template, DBData.IDataObserver<JsonArray> observeData) {
        dictArrayDataPool.observeData(template, observeData);
    }

    public void unObserveDataString(DBTemplate template, DBData.IDataObserver<String> observeData) {
        stringDataPool.unObserveData(template, observeData);
    }

    public void unObserveDataBoolean(DBTemplate template, DBData.IDataObserver<Boolean> observeData) {
        booleanDataPool.unObserveData(template, observeData);
    }

    public void removeObservers(DBTemplate template) {
        stringDataPool.removeObservers(template);
        intDataPool.removeObservers(template);
        booleanDataPool.removeObservers(template);
        dictDataPool.removeObservers(template);
        dictArrayDataPool.removeObservers(template);
    }

    public void changeStringData(DBTemplate template, String key, String value) {
        stringDataPool.changeData(template, key, value);
    }

    public void changeIntData(DBTemplate template, String key, int value) {
        intDataPool.changeData(template, key, value);
    }

    public void changeBooleanData(DBTemplate template, String key, boolean value) {
        booleanDataPool.changeData(template, key, value);
    }

    public void release() {

    }
}
