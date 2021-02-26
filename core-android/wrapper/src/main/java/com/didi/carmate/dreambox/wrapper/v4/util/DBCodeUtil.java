package com.didi.carmate.dreambox.wrapper.v4.util;

import android.text.TextUtils;

import androidx.collection.LruCache;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class DBCodeUtil {

    private static LruCache<String, String> md5Cache = new LruCache<>(3);

    public static String md5FromCache(String string) {
        String cache = md5Cache.get(string);
        if (!TextUtils.isEmpty(cache)) {
            return cache;
        }
        cache = md5(string);
        md5Cache.put(string, cache);
        return cache;
    }

    public static String md5(String string) {
        if (TextUtils.isEmpty(string)) {
            return "";
        }
        MessageDigest md5;
        try {
            md5 = MessageDigest.getInstance("MD5");
            byte[] bytes = md5.digest(string.getBytes());
            StringBuilder result = new StringBuilder();
            for (byte b : bytes) {
                String temp = Integer.toHexString(b & 0xff);
                if (temp.length() == 1) {
                    temp = "0" + temp;
                }
                result.append(temp);
            }
            return result.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return "";
    }

}
