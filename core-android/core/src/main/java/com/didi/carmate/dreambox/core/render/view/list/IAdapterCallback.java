package com.didi.carmate.dreambox.core.render.view.list;

import com.didi.carmate.dreambox.core.render.view.DBRootView;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/7/2
 */
public interface IAdapterCallback {
    void onBindHeaderView(DBRootView rootView);

    void onBindFooterView(DBRootView rootView);

    void onBindItemView(DBListItemRoot itemRootView, JsonObject data);

    void onBindItemView(DBRootView itemRootView, JsonObject data);
}
