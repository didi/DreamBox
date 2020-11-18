package com.didi.carmate.dreambox.core.utils;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.wrapper.Wrapper;

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
