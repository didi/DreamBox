package com.didi.carmate.dreambox.core.constraint.render.view.list;

import com.didi.carmate.dreambox.core.constraint.render.view.DBConstraintView;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/7/2
 */
public abstract class AdapterCallback implements IAdapterCallback {
    public void onBindHeaderView(DBConstraintView rootView) {
    }

    public void onBindFooterView(DBConstraintView rootView) {
    }

    public void onBindItemView(DBListItemRoot itemRootView, JsonObject data) {
    }

    public void onBindItemView(DBConstraintView itemRootView, JsonObject data) {

    }
}
