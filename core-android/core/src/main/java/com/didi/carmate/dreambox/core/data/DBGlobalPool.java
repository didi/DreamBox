package com.didi.carmate.dreambox.core.data;

import java.util.HashMap;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/6/16
 */
public class DBGlobalPool {
    // 全局数据池
    private static Map<String, DBGlobalPool> mGlobalPool = new HashMap<>();
    private Map<String, Object> mData = new HashMap<>();

    public static DBGlobalPool get(String accessKey) {
        DBGlobalPool globalPool = mGlobalPool.get(accessKey);
        if (null == globalPool) {
            globalPool = new DBGlobalPool();
            mGlobalPool.put(accessKey, globalPool);
        }
        return globalPool;
    }

    public <D> void addData(String key, D value) {
        mData.put(key, value);
    }

    public <D> D getData(String key, Class<D> clazz) {
        D ret = null;
        Object obj = mData.get(key);
        if (null != obj && obj.getClass().equals(clazz)) {
            ret = (D) obj;
        }
        return ret;
    }
}
