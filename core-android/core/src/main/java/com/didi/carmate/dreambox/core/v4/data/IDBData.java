package com.didi.carmate.dreambox.core.v4.data;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public interface IDBData<T> {
    void observeData(DBData.IDataObserver observeData);

//    void unObserveData(DBData.IDataObserver observeData);
//
//    /**
//     * 移除某个模板所有的属性观察者，主要用户模板销毁时，批量删除
//     */
//    void removeObservers();
//
//    /**
//     * 移除某个模板所有添加进来的属性，主要用户模板销毁时，批量删除
//     */
//    void removeTemplate();

    /**
     * 暴露给外部，用来往属性池里添加新的值，值用来作为view对象、埋点等的数据源可以
     *
     * @param key   属性key
     * @param value 属性值
     */
    void addData(String key, T value);

    /**
     * @param key 属性key
     */
    T getData(String key);
    
    int getSize();

    /**
     * 暴露给外部，用来改版属性的值，同时触发property changed事件给观察者
     *
     * @param key   属性key
     * @param value 新的属性值
     */
    void changeData(String key, T value);

    interface IDataObserver {
        void onDataChanged(String key);

        String getKey();
    }
}
