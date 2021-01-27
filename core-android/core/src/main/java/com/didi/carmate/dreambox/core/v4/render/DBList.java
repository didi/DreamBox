package com.didi.carmate.dreambox.core.v4.render;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.dreambox.core.v4.base.DBCallback;
import com.didi.carmate.dreambox.core.v4.base.DBConstants;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.didi.carmate.dreambox.core.v4.data.DBData;
import com.didi.carmate.dreambox.core.v4.render.view.list.DBSpaceItemDecoration;
import com.didi.carmate.dreambox.core.v4.utils.DBLogger;
import com.didi.carmate.dreambox.core.v4.utils.DBScreenUtils;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;
import com.didi.carmate.dreambox.core.v4.base.DBBaseView;
import com.didi.carmate.dreambox.core.v4.base.DBContainer;
import com.didi.carmate.dreambox.core.v4.render.view.list.AdapterCallback;
import com.didi.carmate.dreambox.core.v4.render.view.list.DBListAdapter;
import com.didi.carmate.dreambox.core.v4.render.view.list.DBListInnerAdapter;
import com.didi.carmate.dreambox.core.v4.render.view.list.DBListView;
import com.didi.carmate.dreambox.core.v4.render.view.list.IAdapterCallback;
import com.didi.carmate.dreambox.core.v4.render.view.list.IRefreshListener;
import com.didi.carmate.dreambox.core.v4.render.view.list.OnLoadMoreListener;
import com.google.gson.JsonObject;

import java.util.List;
import java.util.Map;

import static com.didi.carmate.dreambox.core.v4.base.DBConstants.PAYLOAD_LIST_FOOTER;
import static com.didi.carmate.dreambox.core.v4.base.DBConstants.PAYLOAD_LIST_VH;

/**
 * author: chenjing
 * date: 2020/5/11
 */
public class DBList extends DBBaseView<DBListView> {
    private String orientation;
    private List<JsonObject> src;
    private int hSpace;
    private int vSpace;
    private boolean pullRefresh;
    private boolean loadMore;
    // private int pageIndex;
    // private int pageSize;
    // private int pageCount;
    // private int pageNext;
    private DBListAdapter mAdapter;
    private DBListInnerAdapter mInnerAdapter;

    private boolean scrollListenerRegisted = false;

    public interface OnScrollListener {
        void onScrolled(@NonNull RecyclerView view, @NonNull String templateId);
    }

    private final RecyclerView.OnScrollListener oneListener = new RecyclerView.OnScrollListener() {

        @Override
        public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
            super.onScrolled(recyclerView, dx, dy);
            if (DBContext.listScrollListeners != null) {
                List<OnScrollListener> developerSetListeners = DBContext.listScrollListeners.get(mDBContext.getAccessKey());
                if (developerSetListeners != null) {
                    for (OnScrollListener listener : developerSetListeners) {
                        listener.onScrolled(recyclerView, mDBContext.getTemplateId());
                    }
                }
            }
        }

    };

    private DBList(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected DBListView onCreateView() {
        return new DBListView(mDBContext);
    }

    @Override
    protected void onAttributesBind(Map<String, String> attrs) {
        super.onAttributesBind(attrs);
        // pullRefresh
        String rawPullRefresh = attrs.get("pullRefresh");
        if (DBUtils.isEmpty(rawPullRefresh)) {
            this.pullRefresh = false;
        } else {
            this.pullRefresh = "true".equals(rawPullRefresh);
        }
        // loadMore
        String rawLoadMore = attrs.get("loadMore");
        if (DBUtils.isEmpty(rawLoadMore)) {
            this.loadMore = false;
        } else {
            this.loadMore = "true".equals(rawLoadMore);
        }
        // pageIndex
//        String rawPageIndex = attrs.get("pageIndex");
//        if (DBUtils.isEmpty(rawPageIndex)) {
//            this.pageIndex = 0;
//        } else {
//            this.pageIndex = DBUtils.isNumeric(rawPageIndex) ? Integer.parseInt(rawPageIndex) : 0;
//        }
        // orientation
        orientation = attrs.get("orientation");
        if (DBUtils.isEmpty(orientation)) {
            orientation = DBConstants.LIST_ORIENTATION_V;
        }
        // 因为数据源需要从各个Item里获取，所以Item子节点属性处理在Adapter的[onBindItemView]回调里处理
        src = getJsonObjectList(attrs.get("src"));
        hSpace = DBScreenUtils.processSize(mDBContext, attrs.get("hSpace"), 0);
        vSpace = DBScreenUtils.processSize(mDBContext, attrs.get("vSpace"), 0);

        final DBListView nativeView = (DBListView) mNativeView;
        if (pullRefresh || loadMore) {
            nativeView.setOverScrollMode(View.OVER_SCROLL_NEVER);
        } else {
            nativeView.setOverScrollMode(View.OVER_SCROLL_ALWAYS);
        }

        if (null != mInnerAdapter) {
            mInnerAdapter.setData(src);
        }
        if (null != mAdapter) {
            mAdapter.notifyDataSetChanged();
        }
    }

    @Override
    protected void onCallbackBind(final List<DBCallback> callbacks, int position) {
        super.onCallbackBind(callbacks, position);

        final DBListView nativeView = (DBListView) mNativeView;
        // 下拉动作事件触发
        nativeView.setPullRefreshEnabled(pullRefresh);
        nativeView.setOnRefreshListener(new IRefreshListener() {
            @Override
            public void onRefresh() {
                doCallback("onPull", callbacks);
//                // FIXME mock net request
//                DBThreadUtils.runOnMain(new Runnable() {
//                    @Override
//                    public void run() {
//                        selfView.refreshComplete(loadMore ? pageSize : src.size());
//                    }
//                }, 2000);
            }
        });

        // 上拉动作事件触发
        nativeView.setLoadMoreEnabled(loadMore);
        nativeView.setOnLoadMoreListener(new OnLoadMoreListener() {
            @Override
            public void onLoadMore() {
                doCallback("onLoadMore", callbacks);
//                    if (mCurrentCounter < TOTAL_COUNTER) {
//                        // loading more
//                        requestData();
//                    } else {
//                        //the end
//                        recyclerView.setNoMore(true);
//                    }
                nativeView.setNoMore(true);
            }
        });
    }

    @Override
    protected void onChildrenBind(Map<String, String> attrs, List<DBContainer<ViewGroup>> children) {
        super.onChildrenBind(attrs, children);

        DBContainer<ViewGroup> listHeader = null;
        DBContainer<ViewGroup> listVh = null;
        DBContainer<ViewGroup> listFooter = null;
        for (DBContainer<ViewGroup> container : children) {
            switch (container.getAttrs().get(DBConstants.UI_PAYLOAD)) {
                case DBConstants.PAYLOAD_LIST_HEADER:
                    listHeader = container;
                    listHeader.setParentAttrs(attrs);
                    break;
                case PAYLOAD_LIST_VH:
                    listVh = container;
                    listVh.setParentAttrs(attrs);
                    break;
                case PAYLOAD_LIST_FOOTER:
                    listFooter = container;
                    listFooter.setParentAttrs(attrs);
                    break;
            }
        }

        if (null == listVh) {
            throw new RuntimeException("[list] vh node cannot be empty!");
        }

        final DBListView nativeView = (DBListView) mNativeView;
        // adapter
        IAdapterCallback mAdapterCallback = new ListAdapterCallback(listHeader, listVh, listFooter);
        mInnerAdapter = new DBListInnerAdapter(src, mAdapterCallback, orientation, listVh);
        mAdapter = new DBListAdapter(mDBContext, mInnerAdapter, mAdapterCallback, orientation,
                listHeader != null, listFooter != null);
        nativeView.setAdapter(mAdapter);

        // layout manager
        LinearLayoutManager managerVertical = new LinearLayoutManager(mDBContext.getContext());
        if (orientation.equals(DBConstants.LIST_ORIENTATION_H)) {
            managerVertical.setOrientation(LinearLayoutManager.HORIZONTAL);
            nativeView.addItemDecoration(new DBSpaceItemDecoration(hSpace, DBSpaceItemDecoration.HORIZONTAL));
        } else {
            managerVertical.setOrientation(LinearLayoutManager.VERTICAL);
            nativeView.addItemDecoration(new DBSpaceItemDecoration(vSpace, DBSpaceItemDecoration.VERTICAL));
        }
        nativeView.setLayoutManager(managerVertical);

        // header & footer
        if (null != listHeader) {
            mAdapter.addHeaderView(listHeader.onCreateView());
        }
        if (null != listFooter) {
            mAdapter.addFooterView(listFooter.onCreateView());
        }

        if (!scrollListenerRegisted) {
            nativeView.addOnScrollListener(oneListener);
            scrollListenerRegisted = true;
        }
    }

    @Override
    protected void onDataChanged(final String key, final Map<String, String> attrs) {
        mDBContext.observeDataPool(new DBData.IDataObserver() {
            @Override
            public void onDataChanged(String key) {
                DBLogger.d(mDBContext, "key: " + key);
                if (null != mInnerAdapter) {
                    src = getJsonObjectList(attrs.get("src"));
                    mInnerAdapter.setData(src);
                }
            }

            @Override
            public String getKey() {
                return key;
            }
        });
    }

    private static final class ListAdapterCallback extends AdapterCallback {
        private final DBContainer<ViewGroup> mDBListHeader;
        private final DBContainer<ViewGroup> mDBListVh;
        private final DBContainer<ViewGroup> mDBListFooter;

        private ListAdapterCallback(
                DBContainer<ViewGroup> listHeader,
                DBContainer<ViewGroup> listVh,
                DBContainer<ViewGroup> listFooter) {
            mDBListHeader = listHeader;
            mDBListVh = listVh;
            mDBListFooter = listFooter;
        }

        @Override
        public void onBindHeaderView(ViewGroup rootView) {
            // header节点渲染处理
            if (null != mDBListHeader) {
                // 子节点属性处理
                mDBListHeader.parserAttribute();
                mDBListHeader.bindView(rootView, NODE_TYPE.NODE_TYPE_ADAPTER);
            }
        }

        @Override
        public void onBindFooterView(ViewGroup rootView) {
            // footer子节点渲染处理
            if (null != mDBListFooter) {
                // 子节点属性处理
                mDBListFooter.parserAttribute();
                mDBListFooter.bindView(rootView, NODE_TYPE.NODE_TYPE_ADAPTER);
            }
        }

        @Override
        public void onBindItemView(ViewGroup itemRoot, JsonObject data, int position) {
            if (null != mDBListVh) {
                // 子节点属性处理
                mDBListVh.setData(data);
                mDBListVh.parserAttribute();
                // 子节点渲染处理
                mDBListVh.bindView(itemRoot, NODE_TYPE.NODE_TYPE_ADAPTER, false, data, position);
            }
        }
    }

    public static String getNodeTag() {
        return "list";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBList createNode(DBContext dbContext) {
            return new DBList(dbContext);
        }
    }
}
