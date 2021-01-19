package com.didi.carmate.dreambox.core.v4.render.view.list;

import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.dreambox.core.v4.base.DBConstants;
import com.didi.carmate.dreambox.core.v4.base.DBContainer;
import com.google.gson.JsonObject;

import java.util.List;

/**
 * author: chenjing
 * date: 2020/7/1
 */
public class DBListInnerAdapter extends RecyclerView.Adapter<DBListViewHolder> {
    private final IAdapterCallback mAdapterCallback;
    private List<JsonObject> mListData;
    private final String mOrientation;
    private final DBContainer<ViewGroup> mItemViewContainer;
    private int mParentWidth;
    private int mParentHeight;

    public DBListInnerAdapter(List<JsonObject> listData, IAdapterCallback innerAdapterCallback,
                              String orientation, DBContainer<ViewGroup> itemViewContainer) {
        mListData = listData;
        mAdapterCallback = innerAdapterCallback;
        mOrientation = orientation;
        mItemViewContainer = itemViewContainer;
    }

    public void setData(List<JsonObject> listData) {
        mListData = listData;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public DBListViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        ViewGroup itemRoot = mItemViewContainer.onCreateView();
        ViewGroup.LayoutParams lp = itemRoot.getLayoutParams();
        if (null == lp) {
            lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        }
        RecyclerView.LayoutManager layoutManager = ((DBListView) parent).getLayoutManager();
        if (mOrientation.equals(DBConstants.LIST_ORIENTATION_H)) {
            if (mParentHeight == 0 && null != layoutManager) {
                mParentHeight = layoutManager.getHeight();
            }
            lp.height = mParentHeight;
        } else {
            if (mParentWidth == 0 && null != layoutManager) {
                mParentWidth = layoutManager.getWidth();
            }
            lp.width = mParentWidth;
        }
        itemRoot.setLayoutParams(lp);
        return new DBListViewHolder(itemRoot);
    }

    @Override
    public void onBindViewHolder(@NonNull DBListViewHolder holder, int position) {
        if (null != mAdapterCallback) {
            mAdapterCallback.onBindItemView(holder.getRootView(), mListData.get(position));
        }
    }

    @Override
    public int getItemCount() {
        return mListData.size();
    }
}
