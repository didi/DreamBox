package com.didi.carmate.dreambox.core.render.view.list;

import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.dreambox.core.render.view.DBRootView;

/**
 * author: chenjing
 * date: 2020/5/21
 */
class DBListViewHolder extends RecyclerView.ViewHolder {
    private DBRootView dbRootView;
    private DBListItemRoot dbListItemRoot;

    DBListViewHolder(View view) {
        super(view);
    }

    DBListViewHolder(DBRootView rootView) {
        super(rootView);
        dbRootView = rootView;
    }

    DBListViewHolder(DBListItemRoot itemView) {
        super(itemView);
        dbListItemRoot = itemView;
    }

    DBRootView getListRootView() {
        return dbRootView;
    }

    DBListItemRoot getListItemRoot() {
        return dbListItemRoot;
    }
}
