package com.didi.carmate.catalog.page;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.catalog.support.SampleListAdapter;
import com.didi.dreambox.catalog.R;

import java.util.ArrayList;
import java.util.List;

public class CatalogMainActivity extends AppCompatActivity {

    private RecyclerView list;
    private SampleListAdapter adapter;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_catalog_main);
        list = findViewById(R.id.catalog_main_list);
        initView();
    }

    private void initView() {
        adapter = new SampleListAdapter();
        adapter.setDataList(getData());
        adapter.setActivity(this);
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        list.setLayoutManager(layoutManager);
        list.setAdapter(adapter);
    }

    public List<SampleListAdapter.SampleListItem> getData() {
        ArrayList<SampleListAdapter.SampleListItem> arrayList = new ArrayList<>();
        String[] strings = getResources().getStringArray(R.array.item_first_name);
        int[] ints = getResources().getIntArray(R.array.item_first_int);
        if (strings.length == ints.length) {
            for (int i = 0; i < strings.length; i++) {
                SampleListAdapter.SampleListItem sampleListItem = new SampleListAdapter.SampleListItem();
                sampleListItem.name = strings[i];
                sampleListItem.id = ints[i];
                arrayList.add(sampleListItem);
            }
        }
        return arrayList;
    }

}
