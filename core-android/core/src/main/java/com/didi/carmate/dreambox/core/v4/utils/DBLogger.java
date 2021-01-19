package com.didi.carmate.dreambox.core.v4.utils;

import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.wrapper.v4.Wrapper;

/**
 * author: chenjing
 * date: 2020/11/2
 */
public class DBLogger {
    public static void d(DBContext dbContext, String msg) {
        Wrapper.get(dbContext.getAccessKey()).log().d(msg);
    }

    public static void w(DBContext dbContext, String msg) {
        Wrapper.get(dbContext.getAccessKey()).log().w(msg);
    }

    public static void e(DBContext dbContext, String msg) {
        Wrapper.get(dbContext.getAccessKey()).log().e(msg);
    }
}
