package com.didi.carmate.dreambox.core.render.view.list;

import com.didi.carmate.dreambox.core.render.view.DBRootView;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/7/2
 */
public abstract class AdapterCallback implements IAdapterCallback {
    public void onBindHeaderView(DBRootView rootView) {
    }

    public void onBindFooterView(DBRootView rootView) {
    }

    public void onBindItemView(DBListItemRoot itemRootView, JsonObject data) {
    }

    public void onBindItemView(DBRootView itemRootView, JsonObject data) {

    }
}
