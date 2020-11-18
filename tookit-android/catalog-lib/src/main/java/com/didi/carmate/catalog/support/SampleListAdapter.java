package com.didi.carmate.catalog.support;

import android.app.Activity;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.catalog.page.ActionListActivity;
import com.didi.carmate.catalog.page.DBDisplayActivity;
import com.didi.carmate.catalog.page.ExpandListActivity;
import com.didi.carmate.catalog.page.ViewListActivity;
import com.didi.dreambox.catalog.R;

import java.util.ArrayList;
import java.util.List;


public class SampleListAdapter extends RecyclerView.Adapter<SampleListAdapter.SampleViewHolder> {

    protected List<SampleListItem> mDataList = new ArrayList<>();
    protected Activity mActivity;

    @Override
    public SampleViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new SampleViewHolder(parent);
    }

    @Override
    public void onBindViewHolder(SampleViewHolder holder, int position) {
        SampleListItem sampleListItem = mDataList.get(position);
        holder.showView(sampleListItem);
    }

    public void setDataList(List<SampleListItem> dataList) {
        mDataList = dataList;
    }

    public void setActivity(Activity activity) {
        mActivity = activity;
    }

    @Override
    public int getItemCount() {
        return mDataList.size();
    }

    public class SampleViewHolder extends RecyclerView.ViewHolder {

        SampleListItem item;

        public SampleViewHolder(ViewGroup parentView) {
            super(LayoutInflater.from(parentView.getContext()).inflate(R.layout.sample_list_item_layout, parentView, false));
        }

        public void showView(SampleListItem sampleListItem) {
            item = sampleListItem;
            final int id = item.id;
            RelativeLayout itemContainer = (RelativeLayout) itemView.findViewById(R.id.item_container);
            TextView nameTv = (TextView) itemView.findViewById(R.id.item_name);
            itemContainer.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    switch (id) {
                        case 1:
                            Intent intent = new Intent();
                            intent.setClass(mActivity, DBDisplayActivity.class);
                            intent.putExtra("name", "helloworld");
                            mActivity.startActivity(intent);
                            break;
                        case 2:
                            mActivity.startActivity(new Intent(mActivity, ViewListActivity.class));
                            break;
                        case 3:
                            mActivity.startActivity(new Intent(mActivity, ActionListActivity.class));
                            break;
                        case 4:
                            Intent intent2 = new Intent();
                            intent2.setClass(mActivity, DBDisplayActivity.class);
                            intent2.putExtra("name", "cardetect");
                            mActivity.startActivity(intent2);
                            break;
                        case 5:
                            mActivity.startActivity(new Intent(mActivity, ExpandListActivity.class));
                            break;
                        case 99:
                            // 视图/动作节点效果页面
                            Intent intent1 = new Intent();
                            intent1.setClass(mActivity, DBDisplayActivity.class);
                            intent1.putExtra("name", item.dbName);
                            mActivity.startActivity(intent1);
                            break;
                    }
                }
            });
            nameTv.setText(item.name);
        }
    }

    public static class SampleListItem {
        public String name;
        public int id;
        public String dbName;
    }
}
