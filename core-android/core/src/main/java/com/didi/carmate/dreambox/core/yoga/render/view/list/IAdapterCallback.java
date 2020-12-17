package com.didi.carmate.dreambox.core.yoga.render.view.list;

import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/7/2
 */
public interface IAdapterCallback {
    void onBindHeaderView(DBYogaView rootView);

    void onBindFooterView(DBYogaView rootView);

    void onBindItemView(DBListItemRoot itemRootView, JsonObject data);

    void onBindItemView(DBYogaView itemRootView, JsonObject data);
}
