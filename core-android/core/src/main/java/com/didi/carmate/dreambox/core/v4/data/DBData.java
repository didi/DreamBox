package com.didi.carmate.dreambox.core.v4.data;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBData<T> implements IDBData<T> {
    private final Map<String, T> mDataPool = new ConcurrentHashMap<>();
    private final List<IDataObserver> mObservePool = new ArrayList<>();

    DBData() {

    }

    public void observeData(IDataObserver observeData) {
        if (!mObservePool.contains(observeData)) {
            mObservePool.add(observeData);
        }
    }

//    @Override
//    public void unObserveData(IDataObserver observeData) {
//        mObservePool.remove(observeData);
//    }
//
//    /**
//     * 移除某个模板所有的属性观察者，主要用户模板销毁时，批量删除
//     */
//    public void removeObservers() {
//        mObservePool.clear();
//    }
//
//    /**
//     * 移除某个模板所有添加进来的属性，模板销毁时使用
//     */
//    public void removeTemplate() {
//        mDataPool.clear();
//    }

    /**
     * 暴露给外部，用来改版属性的值，同时触发property changed事件给观察者
     *
     * @param key   属性key
     * @param value 新的属性值
     */
    public void changeData(String key, T value) {
        // 更新属性值
        mDataPool.put(key, value);

        // 通知观察者
        for (IDataObserver observer : mObservePool) {
            if ("".equals(observer.getKey()) || key.equals(observer.getKey())) {
                observer.onDataChanged(key);
            }
        }
    }

    /**
     * 暴露给外部，用来往属性池里添加新的值，值用来作为view对象、埋点等的数据源可以
     *
     * @param key   属性key
     * @param value 属性值
     */
    public void addData(String key, T value) {
        // 更新属性值
        mDataPool.put(key, value);
        // 通知观察者
        for (IDataObserver observer : mObservePool) {
            if ("".equals(observer.getKey()) || key.equals(observer.getKey())) {
                observer.onDataChanged(key);
            }
        }
    }

    public T getData(String key) {
        return mDataPool.get(key);
    }
}
