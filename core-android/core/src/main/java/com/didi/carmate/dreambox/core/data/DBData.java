package com.didi.carmate.dreambox.core.data;

import com.didi.carmate.dreambox.core.base.DBTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBData<T> implements IDBData<T> {
    private final Map<DBTemplate, ConcurrentHashMap<String, T>> mDataPool = new HashMap<>();
    private final Map<DBTemplate, List<IDataObserver<T>>> mObservePool = new HashMap<>();

    DBData() {

    }

    public interface IDataObserver<D> {
        void onDataChanged(String key, D oldValue, D newValue);

        String getKey();
    }

    public void observeData(DBTemplate template, IDataObserver<T> observeData) {
        List<IDataObserver<T>> observers = mObservePool.get(template);
        if (null == observers) {
            observers = new ArrayList<>();
            mObservePool.put(template, observers);
        }

        if (!observers.contains(observeData)) {
            observers.add(observeData);
        }
    }

    public void unObserveData(DBTemplate template, IDataObserver<T> observeData) {
        List<IDataObserver<T>> observers = mObservePool.get(template);
        if (null != observers) {
            observers.remove(observeData);
        }
    }

    /**
     * 移除某个模板所有的属性观察者，主要用户模板销毁时，批量删除
     *
     * @param template 模板实例
     */
    public void removeObservers(DBTemplate template) {
        mObservePool.remove(template);
    }

    /**
     * 暴露给外部，用来改版属性的值，同时触发property changed事件给观察者
     *
     * @param template 模板实例
     * @param key      属性key
     * @param value    新的属性值
     */
    public void changeData(DBTemplate template, String key, T value) {
        Map<String, T> properties = mDataPool.get(template);
        if (null != properties) {
            // 更新属性值
            T oldValue = properties.get(key);
            properties.put(key, value);

            // 通知观察者
            List<IDataObserver<T>> observers = mObservePool.get(template);
            if (null != observers) {
                for (IDataObserver<T> observer : observers) {
                    if (key.equals(observer.getKey())) {
                        observer.onDataChanged(key, oldValue, value);
                    }
                }
            }
        }
    }

    /**
     * 暴露给外部，用来往属性池里添加新的值，值用来作为view对象、埋点等的数据源可以
     *
     * @param template 模板实例
     * @param key      属性key
     * @param value    属性值
     */
    public void addData(DBTemplate template, String key, T value) {
        ConcurrentHashMap<String, T> properties = mDataPool.get(template);
        if (null == properties) {
            properties = new ConcurrentHashMap<>();
            mDataPool.put(template, properties);
        }

        // 更新属性值
        T oldValue = properties.get(key);
        properties.put(key, value);
        // 通知观察者
        List<IDataObserver<T>> observers = mObservePool.get(template);
        if (null != observers) {
            for (IDataObserver<T> observer : observers) {
                if (key.equals(observer.getKey())) {
                    observer.onDataChanged(key, oldValue, value);
                }
            }
        }
    }

    /**
     * 移除某个模板所有添加进来的属性，模板销毁时使用
     *
     * @param template dream box对象实例
     */
    public void removeTemplate(DBTemplate template) {
        mDataPool.remove(template);
    }

    public T getData(DBTemplate template, String key) {
        Map<String, T> properties = mDataPool.get(template);
        if (null != properties) {
            return properties.get(key);
        }

        return null;
    }
}
