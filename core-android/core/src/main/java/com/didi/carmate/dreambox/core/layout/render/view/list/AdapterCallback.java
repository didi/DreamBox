package com.didi.carmate.dreambox.core.layout.render.view.list;

import android.view.ViewGroup;

import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/7/2
 */
public abstract class AdapterCallback implements IAdapterCallback {
    public void onBindHeaderView(ViewGroup rootView) {
    }

    public void onBindFooterView(ViewGroup rootView) {
    }

    public void onBindItemView(ViewGroup itemRootView, JsonObject data) {
    }
}
