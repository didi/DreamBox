package com.didi.carmate.dreambox.shell;

import android.text.TextUtils;
import android.util.Base64;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.didi.carmate.dreambox.wrapper.util.DBCodeUtil;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class DreamBoxProcessor {

    private static final int MD5_INFO_LEN = 32;
    private static final int SDK_VER_LEN = 4;
    private static final int EMPTY_INFO_LEN = 20;

    @Nullable
    public String process(@NonNull String accessKey, @NonNull String origin) throws IllegalArgumentException {
        if (TextUtils.isEmpty(origin)) {
            throw new IllegalArgumentException("传入 origin 为空");
        }
        if (TextUtils.isEmpty(accessKey)) {
            throw new IllegalArgumentException("传入 accessKey 为空");
        }

        checkAccessKey(accessKey);

        String md5 = null;
        if (origin.length() >= MD5_INFO_LEN) {
            md5 = origin.substring(0, MD5_INFO_LEN);
            origin = origin.substring(MD5_INFO_LEN);
        }

        String version = null;
        if (origin.length() >= SDK_VER_LEN) {
            version = origin.substring(0, SDK_VER_LEN);
            origin = origin.substring(SDK_VER_LEN);
        }

        checkVersion(version);

        String raw = null;
        if (origin.length() >= EMPTY_INFO_LEN) {
            origin = origin.substring(EMPTY_INFO_LEN);
            raw = new String(Base64.decode(origin, Base64.DEFAULT));
        }

        checkMd5(md5, raw);

        return raw;
    }

    private void checkAccessKey(String key) throws IllegalArgumentException {
        if (!DreamBox.accessKeys.contains(key)) {
            throw new IllegalArgumentException("未初始化AccessKey：" + key);
        }
    }

    private void checkVersion(String version) throws IllegalArgumentException {
        if (TextUtils.isEmpty(version)) {
            throw new IllegalArgumentException("缺少SDK版本校对值");
        }
        int curNum = DreamBox.VERSION_CODE;
        try {
            int originNum = Integer.parseInt(version);
            if (originNum > curNum) {
                throw new IllegalArgumentException("版本验证不通过 当前：" + DreamBox.VERSION + " 传入：" + version);
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("版本验证错误", e);
        }
    }

    private void checkMd5(String md5, String raw) throws IllegalArgumentException {
        if (TextUtils.isEmpty(md5)) {
            throw new IllegalArgumentException("缺少Md5校对值");
        }
        if (TextUtils.isEmpty(raw)) {
            throw new IllegalArgumentException("模板数据为空");
        }
        if (!TextUtils.equals(DBCodeUtil.md5(raw), md5)) {
            throw new IllegalArgumentException("MD5验证错误");
        }
    }

}
