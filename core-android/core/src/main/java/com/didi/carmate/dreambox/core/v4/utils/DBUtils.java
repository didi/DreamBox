package com.didi.carmate.dreambox.core.v4.utils;

import android.graphics.Color;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;

public class DBUtils {

    public static boolean isEmpty(final CharSequence cs) {
        return cs == null || cs.length() == 0;
    }

    public static boolean isNumeric(final CharSequence cs) {
        if (isEmpty(cs)) {
            return false;
        }

        final int sz = cs.length();
        if (!Character.isDigit(cs.charAt(0))) {
            return false;
        }
        if (!Character.isDigit(cs.charAt(sz - 1))) {
            return false;
        }
        for (int i = 0; i < sz; i++) {
            char c = cs.charAt(i);
            if (!Character.isDigit(c) && ".".getBytes()[0] != c) {
                return false;
            }
        }
        return true;
    }

    public static JsonObject fromJson(String strJson) {
        if (!isEmpty(strJson)) {
            try {
                return new Gson().fromJson(strJson, JsonObject.class);
            } catch (JsonSyntaxException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public static boolean isColor(String color) {
        // 简单检查
        return !isEmpty(color) && color.charAt(0) == '#' && (color.length() == 7 || color.length() == 9);
    }

    public static int parseColor(Object view, String color) {
        if (color.charAt(0) != '#' || (color.length() != 7 && color.length() != 9)) {
            String errorMsg = " type: " + view.getClass().getSimpleName() +
                    ", Unknown color: " + color;
            throw new IllegalArgumentException(errorMsg);
        }
        return Color.parseColor(color);
    }
}
