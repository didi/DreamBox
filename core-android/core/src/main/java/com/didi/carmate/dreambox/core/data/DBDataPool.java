package com.didi.carmate.dreambox.core.data;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;

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

    private final List<DBData.IDataObserver> observerList = new ArrayList<>();

    public DBDataPool() {
        // 接收任何key值变化产生的事件
        IDBData.IDataObserver dataObserver = new IDBData.IDataObserver() {
            @Override
            public void onDataChanged(String key) {
                for (IDBData.IDataObserver observer : observerList) {
                    if (observer.getKey().contains(key)) { // key路径是包含关系的，也进行通知
                        observer.onDataChanged(key);
                    }
                }
            }

            @Override
            public String getKey() {
                return ""; // 接收任何key值变化产生的事件
            }
        };
        stringDataPool.observeData(dataObserver);
        booleanDataPool.observeData(dataObserver);
        intDataPool.observeData(dataObserver);
        dictDataPool.observeData(dataObserver);
        dictArrayDataPool.observeData(dataObserver);
    }

    public void putData(String key, String value) {
        stringDataPool.addData(key, value);
    }

    public void putData(String key, int value) {
        intDataPool.addData(key, value);
    }

    public void putData(String key, boolean value) {
        booleanDataPool.addData(key, value);
    }

    public void putData(String key, JsonObject value) {
        dictDataPool.addData(key, value);
    }

    public void putData(String key, JsonArray value) {
        dictArrayDataPool.addData(key, value);
    }

    public String getString(String key) {
        String value = stringDataPool.getData(key);
        if (null == value) {
            return "";
        } else {
            return value;
        }
    }

    public int getInt(String key) {
        Integer value = intDataPool.getData(key);
        if (null == value) {
            return -1;
        } else {
            return value;
        }
    }

    public boolean getBoolean(String key) {
        Boolean value = booleanDataPool.getData(key);
        if (null == value) {
            return false;
        }
        return value;
    }

    public JsonObject getDict(String key) {
        return dictDataPool.getData(key);
    }

    public JsonArray getDictArray(String key) {
        return dictArrayDataPool.getData(key);
    }

    public void observeDataPool(DBData.IDataObserver observeData) {
        if (!observerList.contains(observeData)) {
            observerList.add(observeData);
        }
    }

//    public void unObserveDataString(DBTemplate template, DBData.IDataObserver observeData) {
//        stringDataPool.unObserveData(template, observeData);
//    }
//
//    public void unObserveDataBoolean(DBTemplate template, DBData.IDataObserver observeData) {
//        booleanDataPool.unObserveData(template, observeData);
//    }
//
//    public void removeObservers(DBTemplate template) {
//        stringDataPool.removeObservers(template);
//        intDataPool.removeObservers(template);
//        booleanDataPool.removeObservers(template);
//        dictDataPool.removeObservers(template);
//        dictArrayDataPool.removeObservers(template);
//    }

    public void changeStringData(String key, String value) {
        stringDataPool.changeData(key, value);
    }

    public void changeIntData(String key, int value) {
        intDataPool.changeData(key, value);
    }

    public void changeBooleanData(String key, boolean value) {
        booleanDataPool.changeData(key, value);
    }

    public void release() {

    }
}
