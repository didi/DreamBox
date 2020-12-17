package com.didi.carmate.dreambox.core.yoga.render;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.data.DBData;
import com.didi.carmate.dreambox.core.utils.DBLogger;
import com.didi.carmate.dreambox.core.utils.DBScreenUtils;
import com.didi.carmate.dreambox.core.yoga.base.DBBaseView;
import com.didi.carmate.dreambox.core.yoga.base.DBContainer;
import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;
import com.didi.carmate.dreambox.core.yoga.render.view.flow.DBFlowAdapter;
import com.didi.carmate.dreambox.core.yoga.render.view.flow.DBFlowLayout;
import com.didi.carmate.dreambox.core.yoga.render.view.list.AdapterCallback;
import com.google.gson.JsonObject;

import java.util.List;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/11
 */
public class DBFlow extends DBBaseView<DBFlowLayout> {
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

        src = getJsonObjectList(attrs.get("src"));
        hSpace = DBScreenUtils.processSize(mDBContext, attrs.get("hSpace"), 0);
        vSpace = DBScreenUtils.processSize(mDBContext, attrs.get("vSpace"), 0);
        // 因为数据源需要从各个Item里获取，所以Item子节点属性处理在Adapter的[onBindItemView]回调里处理
    }

    @Override
    protected DBFlowLayout onCreateView() {
        return new DBFlowLayout(mDBContext);
    }

    @Override
    protected void onChildrenBind(Map<String, String> attrs, List<DBContainer<?>> children) {
        super.onChildrenBind(attrs, children);

        // 子节点渲染处理在Adapter的[onBindViewHolder]回调里处理
        DBContainer<DBYogaView> cell = null;
        for (DBContainer<?> container : children) {
            if (container instanceof DBCell) {
                cell = (DBCell) container;
                cell.setParentAttrs(attrs);
            }
        }

        DBFlowLayout flowLayout = (DBFlowLayout) mNativeView;
        FlowAdapterCallback adapterCallback = new FlowAdapterCallback(mDBContext, cell);
        mAdapter = new DBFlowAdapter<>(mDBContext, flowLayout, src, adapterCallback, cell);

        flowLayout.setAdapter(mAdapter);
        flowLayout.setChildSpacing(hSpace);
        flowLayout.setRowSpacing(vSpace);
    }

    @Override
    protected void onDataChanged(final String key, final Map<String, String> attrs) {
        mDBContext.observeDataPool(new DBData.IDataObserver() {
            @Override
            public void onDataChanged(String key) {
                DBLogger.d(mDBContext, "key: " + key);
                if (null != mAdapter) {
                    src = getJsonObjectList(attrs.get("src"));
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
        private final DBContainer<DBYogaView> mFlowCell;

        private FlowAdapterCallback(DBContext dbContext, DBContainer<DBYogaView> flowCell) {
            mDBContext = dbContext;
            mFlowCell = flowCell;
        }

        @Override
        public void onBindItemView(DBYogaView itemRoot, JsonObject data) {
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
