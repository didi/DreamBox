package com.didi.carmate.dreambox.core.layout.render.view.list;

import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.dreambox.core.layout.render.view.DBYogaLayoutView;

/**
 * author: chenjing
 * date: 2020/5/21
 */
class DBListViewHolder extends RecyclerView.ViewHolder {
    private DBYogaLayoutView dbRootView;
    private ViewGroup dbListItemRoot;

    DBListViewHolder(View view) {
        super(view);
    }

    DBListViewHolder(DBYogaLayoutView rootView) {
        super(rootView);
        dbRootView = rootView;
    }

    DBListViewHolder(ViewGroup itemView) {
        super(itemView);
        dbListItemRoot = itemView;
    }

    DBYogaLayoutView getListRootView() {
        return dbRootView;
    }

    ViewGroup getListItemRoot() {
        return dbListItemRoot;
    }
}
