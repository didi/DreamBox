package com.didi.carmate.dreambox.core.v4.render.view.list;

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
    private final int edgeStart;
    private final int edgeEnd;

    public DBSpaceItemDecoration(int space, int orientation, int edgeStart, int edgeEnd) {
        this.space = space;
        this.orientation = orientation;
        this.edgeStart = edgeStart;
        this.edgeEnd = edgeEnd;
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, RecyclerView parent,
                               @NonNull RecyclerView.State state) {
        int position = parent.getChildAdapterPosition(view);

        if (position > 0) { // 第0个是指示器, 第1个两边都加
            if (position == 1) {
                if (orientation == VERTICAL) {
                    outRect.top = edgeStart;
                } else {
                    outRect.left = edgeEnd;
                }
            }
            if (position == parent.getAdapter().getItemCount() - 1) {
                if (orientation == VERTICAL) {
                    outRect.bottom = edgeEnd;
                } else {
                    outRect.right = edgeEnd;
                }
            } else {
                if (orientation == VERTICAL) {
                    outRect.bottom = space;
                } else {
                    outRect.right = space;
                }
            }
        }

//        if (position > 0) { // 第1个只加一边
//            if (position != 1) {
//                if (orientation == VERTICAL) {
//                    outRect.top = space;
//                } else {
//                    outRect.left = space;
//                }
//            }
//        }
    }
}
