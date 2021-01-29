package com.didi.carmate.dreambox.core.v4.base;

import android.view.View;

import com.google.gson.JsonObject;

/**
 * Author: chenjing
 * Date: 2021/1/29 1:54 AM
 */
public class DBModel {
    private int id;
    private View mView;
    private JsonObject mData;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public View getView() {
        return mView;
    }

    public void setView(View view) {
        this.mView = view;
    }

    public JsonObject getData() {
        return mData;
    }

    public void setData(JsonObject mData) {
        this.mData = mData;
    }
}
