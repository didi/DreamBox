package com.didi.carmate.dreambox.core.render.view.list;

import android.graphics.Rect;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public class DBSpaceItemDecoration extends RecyclerView.ItemDecoration {
    public static final int HORIZONTAL = LinearLayout.HORIZONTAL;
    public static final int VERTICAL = LinearLayout.VERTICAL;
    private final int space;
    private final int orientation;

    public DBSpaceItemDecoration(int space, int orientation) {
        this.space = space;
        this.orientation = orientation;
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, RecyclerView parent,
                               @NonNull RecyclerView.State state) {
        if (parent.getChildAdapterPosition(view) == 0) {
            if (orientation == VERTICAL) {
                outRect.top = space;
            } else {
                outRect.left = space;
            }
        }
        if (orientation == VERTICAL) {
            outRect.bottom = space;
        } else {
            outRect.right = space;
        }
    }
}
