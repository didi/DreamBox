package com.didi.carmate.dreambox.core.constraint.render.view.list;

import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.dreambox.core.constraint.render.view.DBConstraintView;

/**
 * author: chenjing
 * date: 2020/5/21
 */
class DBListViewHolder extends RecyclerView.ViewHolder {
    private DBConstraintView dbRootView;
    private DBListItemRoot dbListItemRoot;

    DBListViewHolder(View view) {
        super(view);
    }

    DBListViewHolder(DBConstraintView rootView) {
        super(rootView);
        dbRootView = rootView;
    }

    DBListViewHolder(DBListItemRoot itemView) {
        super(itemView);
        dbListItemRoot = itemView;
    }

    DBConstraintView getListRootView() {
        return dbRootView;
    }

    DBListItemRoot getListItemRoot() {
        return dbListItemRoot;
    }
}
