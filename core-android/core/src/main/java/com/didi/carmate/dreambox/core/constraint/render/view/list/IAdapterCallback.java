package com.didi.carmate.dreambox.core.constraint.render.view.list;

import com.didi.carmate.dreambox.core.constraint.render.view.DBConstraintView;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/7/2
 */
public interface IAdapterCallback {
    void onBindHeaderView(DBConstraintView rootView);

    void onBindFooterView(DBConstraintView rootView);

    void onBindItemView(DBListItemRoot itemRootView, JsonObject data);

    void onBindItemView(DBConstraintView itemRootView, JsonObject data);
}
