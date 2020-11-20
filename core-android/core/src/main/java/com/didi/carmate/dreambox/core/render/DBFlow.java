package com.didi.carmate.dreambox.core.render;

import com.didi.carmate.dreambox.core.base.DBBaseView;
import com.didi.carmate.dreambox.core.base.DBContainer;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.data.DBData;
import com.didi.carmate.dreambox.core.render.view.DBRootView;
import com.didi.carmate.dreambox.core.render.view.flow.DBFlowAdapter;
import com.didi.carmate.dreambox.core.render.view.flow.DBFlowLayout;
import com.didi.carmate.dreambox.core.render.view.list.AdapterCallback;
import com.didi.carmate.dreambox.core.utils.DBLogger;
import com.didi.carmate.dreambox.core.utils.DBScreenUtils;
import com.google.gson.JsonObject;

import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/11
 */
public class DBFlow extends DBBaseView<DBFlowLayout> {
    private String rawSrc;
    private DBFlowAdapter<JsonObject> mAdapter;
    private List<JsonObject> src;
    private int hSpace;
    private int vSpace;

    protected DBFlow(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        rawSrc = attrs.get("src");
        src = getJsonObjectList(rawSrc);
        hSpace = DBScreenUtils.processSize(mDBContext, attrs.get("hSpace"), 0);
        vSpace = DBScreenUtils.processSize(mDBContext, attrs.get("vSpace"), 0);
        // 因为数据源需要从各个Item里获取，所以Item子节点属性处理在Adapter的[onBindItemView]回调里处理
    }

    @Override
    protected DBFlowLayout onCreateView() {
        return new DBFlowLayout(mDBContext);
    }

    @Override
    protected void onChildrenBind(DBFlowLayout selfView, Map<String, String> attrs, List<DBContainer<?>> children) {
        super.onChildrenBind(selfView, attrs, children);

        // 子节点渲染处理在Adapter的[onBindViewHolder]回调里处理
        DBContainer<DBRootView> cell = null;
        for (DBContainer<?> container : children) {
            if (container instanceof DBCell) {
                cell = (DBCell) container;
                cell.setParentAttrs(attrs);
            }
        }

        FlowAdapterCallback adapterCallback = new FlowAdapterCallback(mDBContext, cell);
        mAdapter = new DBFlowAdapter<>(mDBContext, selfView, src, adapterCallback, cell);

        selfView.setAdapter(mAdapter);
        selfView.setChildSpacing(hSpace);
        selfView.setRowSpacing(vSpace);
    }

    @Override
    protected void onDataChanged(final DBFlowLayout selfView, final String key) {
        mDBContext.observeJsonObjectData(new DBData.IDataObserver<JsonObject>() {
            @Override
            public void onDataChanged(String key, JsonObject oldValue, JsonObject newValue) {
                DBLogger.d(mDBContext, "key: " + key + " oldValue: " + oldValue + " newValue: " + newValue);
                if (null != newValue && null != mAdapter) {
                    src = getJsonObjectList(rawSrc);
                    mAdapter.setData(src);
                }
            }

            @Override
            public String getKey() {
                return key;
            }
        });
    }

    private static final class FlowAdapterCallback extends AdapterCallback {
        private final DBContext mDBContext;
        private final DBContainer<DBRootView> mFlowCell;

        private FlowAdapterCallback(DBContext dbContext, DBContainer<DBRootView> flowCell) {
            mDBContext = dbContext;
            mFlowCell = flowCell;
        }

        @Override
        public void onBindItemView(DBRootView itemRoot, JsonObject data) {
            if (null == mFlowCell) {
                DBLogger.e(mDBContext, "flow child can not be null.");
                return;
            }

            // 子节点属性处理
            mFlowCell.setData(data);
            mFlowCell.parserAttribute();
            // 子节点渲染处理
            mFlowCell.bindView(itemRoot);
        }
    }

    public static String getNodeTag() {
        return "flow";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBFlow createNode(DBContext dbContext) {
            return new DBFlow(dbContext);
        }
    }
}
