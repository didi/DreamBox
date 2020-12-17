package com.didi.carmate.dreambox.core.yoga.render.view.flow;

import android.view.View;
import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.yoga.base.DBContainer;
import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;
import com.didi.carmate.dreambox.core.yoga.render.view.list.IAdapterCallback;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;

/**
 * author: chenjing
 * date: 2020/7/14
 */
public class DBFlowAdapter<E> extends DBFlowLayout.FlowAdapter<E> {
    private final IAdapterCallback mAdapterCallback;
    private final DBContainer<DBYogaView> mCellContainer;
    private List<JsonObject> mDataList;

    public DBFlowAdapter(DBContext dbContext, ViewGroup viewGroup, List<JsonObject> dataList,
                         IAdapterCallback adapterCallback,
                         DBContainer<DBYogaView> cellContainer) {
        super(dbContext.getContext(), viewGroup);
        mAdapterCallback = adapterCallback;
        mCellContainer = cellContainer;
        mDataList = (dataList == null) ? new ArrayList<JsonObject>() : dataList;
    }

    public void setData(List<JsonObject> listData) {
        mDataList = listData;
        notifyDataSetChanged();
    }

    @Override
    View getView(int index) {
        DBYogaView rootView = mCellContainer.onCreateView();
        if (null != mAdapterCallback) {
            mAdapterCallback.onBindItemView(rootView, mDataList.get(index));
        }
        return rootView;
    }

    @Override
    int getCount() {
        return mDataList.size();
    }
}
