package com.didi.carmate.dreambox.wrapper.inner;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.RestrictTo;

import java.util.UUID;

@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public class WrapperUtils {

    private static final String SP_NAME = "dreambox";
    private static final String SP_UUID = "uniqueId";

    public static String getUUID(@NonNull Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
        String uniqueId = sharedPreferences.getString(SP_UUID, "");
        if (TextUtils.isEmpty(uniqueId)) {
            uniqueId = UUID.randomUUID().toString();
            sharedPreferences.edit().putString(SP_UUID, uniqueId).apply();
        }
        return uniqueId;
    }

}
