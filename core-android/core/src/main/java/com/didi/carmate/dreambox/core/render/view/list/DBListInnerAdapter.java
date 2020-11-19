package com.didi.carmate.dreambox.core.render.view.list;

import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContainer;
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
    private final DBContainer<DBListItemRoot> mItemViewContainer;
    private int mParentWidth;
    private int mParentHeight;

    public DBListInnerAdapter(List<JsonObject> listData, IAdapterCallback innerAdapterCallback,
                              String orientation, DBContainer<DBListItemRoot> itemViewContainer) {
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
        DBListItemRoot itemRoot = mItemViewContainer.onCreateView();
        ViewGroup.LayoutParams lp = itemRoot.getLayoutParams();
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
            mAdapterCallback.onBindItemView(holder.getListItemRoot(), mListData.get(position));
        }
    }

    @Override
    public int getItemCount() {
        return mListData.size();
    }
}
