package com.didi.carmate.dreambox.core.layout.render.view.list;

import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

/**
 * author: chenjing
 * date: 2020/5/21
 */
class DBListViewHolder extends RecyclerView.ViewHolder {
    private ViewGroup mRootView;

    DBListViewHolder(View view) {
        super(view);
    }

    DBListViewHolder(ViewGroup rootView) {
        super(rootView);
        mRootView = rootView;
    }

    ViewGroup getRootView() {
        return mRootView;
    }
}
