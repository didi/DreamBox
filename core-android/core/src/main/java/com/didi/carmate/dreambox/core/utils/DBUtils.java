package com.didi.carmate.dreambox.core.utils;

import android.app.Application;
import android.content.pm.ApplicationInfo;
import android.graphics.Color;

import com.didi.carmate.dreambox.core.base.DBAbsView;
import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBBaseView;
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

    public static int parseColor(DBAbsView<?> view, String color) {
        if (color.charAt(0) != '#' || (color.length() != 7 && color.length() != 9)) {
            StringBuilder errorMsg = new StringBuilder();
            if (view.getId() != DBConstants.DEFAULT_ID_VIEW) {
                errorMsg.append("id: ").append(view.getId()).append(",");
            }
            errorMsg.append(" type: ").append(view.getClass().getSimpleName())
                    .append(", Unknown color: ").append(color);
            throw new IllegalArgumentException(errorMsg.toString());
        }
        return Color.parseColor(color);
    }

    public static boolean isAppDebug(Application application) {
        return 0 != (application.getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE);
    }
}
