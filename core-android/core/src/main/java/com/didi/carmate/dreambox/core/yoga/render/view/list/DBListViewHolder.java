package com.didi.carmate.dreambox.core.yoga.render.view.list;

import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;

/**
 * author: chenjing
 * date: 2020/5/21
 */
class DBListViewHolder extends RecyclerView.ViewHolder {
    private DBYogaView dbRootView;
    private DBListItemRoot dbListItemRoot;

    DBListViewHolder(View view) {
        super(view);
    }

    DBListViewHolder(DBYogaView rootView) {
        super(rootView);
        dbRootView = rootView;
    }

    DBListViewHolder(DBListItemRoot itemView) {
        super(itemView);
        dbListItemRoot = itemView;
    }

    DBYogaView getListRootView() {
        return dbRootView;
    }

    DBListItemRoot getListItemRoot() {
        return dbListItemRoot;
    }
}
