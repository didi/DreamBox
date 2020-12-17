package com.didi.carmate.dreambox.core.yoga.render.view.list;

import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/7/2
 */
public abstract class AdapterCallback implements IAdapterCallback {
    public void onBindHeaderView(DBYogaView rootView) {
    }

    public void onBindFooterView(DBYogaView rootView) {
    }

    public void onBindItemView(DBListItemRoot itemRootView, JsonObject data) {
    }

    public void onBindItemView(DBYogaView itemRootView, JsonObject data) {

    }
}
