package com.didi.carmate.dreambox.core.render;

import android.view.View;

import androidx.recyclerview.widget.LinearLayoutManager;

import com.didi.carmate.dreambox.core.base.DBBaseView;
import com.didi.carmate.dreambox.core.base.DBCallback;
import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContainer;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.render.view.DBRootView;
import com.didi.carmate.dreambox.core.render.view.list.AdapterCallback;
import com.didi.carmate.dreambox.core.render.view.list.DBListAdapter;
import com.didi.carmate.dreambox.core.render.view.list.DBListInnerAdapter;
import com.didi.carmate.dreambox.core.render.view.list.DBListItemRoot;
import com.didi.carmate.dreambox.core.render.view.list.DBListView;
import com.didi.carmate.dreambox.core.render.view.list.IAdapterCallback;
import com.didi.carmate.dreambox.core.render.view.list.IRefreshListener;
import com.didi.carmate.dreambox.core.render.view.list.OnLoadMoreListener;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.google.gson.JsonObject;

import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/11
 */
public class DBList extends DBBaseView<DBListView> {
    private String orientation;
    private List<JsonObject> src;
    private boolean pullRefresh;
    private boolean loadMore;
    // private int pageIndex;
    // private int pageSize;
    // private int pageCount;
    // private int pageNext;
    private DBListInnerAdapter mInnerAdapter;

    private DBList(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected DBListView onCreateView() {
        return new DBListView(mDBContext);
    }

    @Override
    protected void onAttributesBind(DBListView selfView, Map<String, String> attrs) {
        super.onAttributesBind(selfView, attrs);
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

        if (pullRefresh || loadMore) {
            selfView.setOverScrollMode(View.OVER_SCROLL_NEVER);
        } else {
            selfView.setOverScrollMode(View.OVER_SCROLL_ALWAYS);
        }
    }

    @Override
    protected void onCallbackBind(final DBListView selfView, final List<DBCallback> callbacks) {
        super.onCallbackBind(selfView, callbacks);

        selfView.setOnRefreshListener(new IRefreshListener() {
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

        selfView.setOnLoadMoreListener(new OnLoadMoreListener() {
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
                selfView.setNoMore(true);
            }
        });
    }

    @Override
    protected void onChildrenBind(DBListView selfView, Map<String, String> attrs, List<DBContainer<?>> children) {
        super.onChildrenBind(selfView, attrs, children);

        DBContainer<DBRootView> listHeader = null;
        DBContainer<DBListItemRoot> listVh = null;
        DBContainer<DBRootView> listFooter = null;
        for (DBContainer<?> container : children) {
            if (container instanceof DBListHeader) {
                listHeader = (DBListHeader) container;
                listHeader.setParentAttrs(attrs);
            } else if (container instanceof DBListFooter) {
                listFooter = (DBListFooter) container;
                listFooter.setParentAttrs(attrs);
            } else if (container instanceof DBListVh) {
                listVh = (DBListVh) container;
                listVh.setParentAttrs(attrs);
            }
        }

        if (null == listVh) {
            throw new RuntimeException("[list] vh node cannot be empty!");
        }

        // adapter
        IAdapterCallback mAdapterCallback = new ListAdapterCallback(listHeader, listVh, listFooter);
        mInnerAdapter = new DBListInnerAdapter(src, mAdapterCallback, orientation, listVh);
        DBListAdapter mAdapter = new DBListAdapter(mInnerAdapter, mAdapterCallback, orientation,
                listHeader != null, listFooter != null);
        selfView.setAdapter(mAdapter);

        // layout manager
        LinearLayoutManager managerVertical = new LinearLayoutManager(mDBContext.getContext());
        if (orientation.equals(DBConstants.LIST_ORIENTATION_H)) {
            managerVertical.setOrientation(LinearLayoutManager.HORIZONTAL);
        } else {
            managerVertical.setOrientation(LinearLayoutManager.VERTICAL);
        }
        selfView.setLayoutManager(managerVertical);

        // header & footer
        if (null != listHeader) {
            mAdapter.addHeaderView(listHeader.onCreateView());
        }
        if (null != listFooter) {
            mAdapter.addFooterView(listFooter.onCreateView());
        }
        // 下拉动作事件触发
        selfView.setPullRefreshEnabled(pullRefresh);
        // 上拉动作事件触发
        selfView.setLoadMoreEnabled(loadMore);
    }

    @Override
    public void changeOnCallback(DBListView selfView, String key, String oldValue, String newValue) {
        if (null != newValue && null != mInnerAdapter) {
            src = getJsonObjectList(newValue);
            mInnerAdapter.setData(src);
        }
    }

    private static final class ListAdapterCallback extends AdapterCallback {
        private final DBContainer<DBRootView> mDBListHeader;
        private final DBContainer<DBListItemRoot> mDBListVh;
        private final DBContainer<DBRootView> mDBListFooter;

        private ListAdapterCallback(
                DBContainer<DBRootView> listHeader,
                DBContainer<DBListItemRoot> listVh,
                DBContainer<DBRootView> listFooter) {
            mDBListHeader = listHeader;
            mDBListVh = listVh;
            mDBListFooter = listFooter;
        }

        @Override
        public void onBindHeaderView(DBRootView rootView) {
            // header节点渲染处理
            if (null != mDBListHeader) {
                // 子节点属性处理
                mDBListHeader.parserAttribute();
                mDBListHeader.bindView(rootView);
            }
        }

        @Override
        public void onBindFooterView(DBRootView rootView) {
            // footer子节点渲染处理
            if (null != mDBListFooter) {
                // 子节点属性处理
                mDBListFooter.parserAttribute();
                mDBListFooter.bindView(rootView);
            }
        }

        @Override
        public void onBindItemView(DBListItemRoot itemRoot, JsonObject data) {
            if (null != mDBListVh) {
                // 子节点属性处理
                mDBListVh.setData(data);
                mDBListVh.parserAttribute();
                // 子节点渲染处理
                mDBListVh.bindView(itemRoot);
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
