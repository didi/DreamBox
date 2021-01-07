package com.didi.carmate.dreambox.core;

import android.app.Application;
import android.content.Context;

import androidx.annotation.WorkerThread;
import androidx.lifecycle.Lifecycle;

import com.didi.carmate.dreambox.core.action.DBActionAlias;
import com.didi.carmate.dreambox.core.action.DBActions;
import com.didi.carmate.dreambox.core.action.DBChangeMeta;
import com.didi.carmate.dreambox.core.action.DBClosePage;
import com.didi.carmate.dreambox.core.action.DBDialog;
import com.didi.carmate.dreambox.core.action.DBInvoke;
import com.didi.carmate.dreambox.core.action.DBLog;
import com.didi.carmate.dreambox.core.action.DBNav;
import com.didi.carmate.dreambox.core.action.DBNet;
import com.didi.carmate.dreambox.core.action.DBStorage;
import com.didi.carmate.dreambox.core.action.DBToast;
import com.didi.carmate.dreambox.core.action.DBTrace;
import com.didi.carmate.dreambox.core.action.DBTraceAttr;
import com.didi.carmate.dreambox.core.base.DBCallbacks;
import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBNodeParser;
import com.didi.carmate.dreambox.core.base.DBNodeRegistry;
import com.didi.carmate.dreambox.core.base.DBTemplate;
import com.didi.carmate.dreambox.core.base.IDBCoreView;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.bridge.DBSendEvent;
import com.didi.carmate.dreambox.core.bridge.DBSendEventMsg;
import com.didi.carmate.dreambox.core.data.DBGlobalPool;
import com.didi.carmate.dreambox.core.data.DBMeta;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.facebook.soloader.SoLoader;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/5/6
 */
public class DBEngine {
    private static volatile DBEngine sInstance;

    private Application mApplication;
    private DBNodeRegistry mNodeRegistry;

    private DBEngine() {
    }

    public static DBEngine getInstance() {
        if (sInstance == null) {
            synchronized (DBEngine.class) {
                if (sInstance == null) {
                    sInstance = new DBEngine();
                }
            }
        }
        return sInstance;
    }

    public void init(Application application) {
        mApplication = application;
        mNodeRegistry = new DBNodeRegistry();
        initInternal();

        SoLoader.init(application, false);
    }

    public Application getApplication() {
        return mApplication;
    }

    @WorkerThread
    public synchronized JsonObject extWrapper(String extJsonObject) {
        JsonObject extJson = null;
        if (!DBUtils.isEmpty(extJsonObject)) {
            extJson = new Gson().fromJson(extJsonObject, JsonObject.class);
        }
        return extJson;
    }

    @WorkerThread
    public synchronized DBTemplate parser(String accessKey, String templateId, String dblTemplate) {
        DBContext dbContext = new DBContext(mApplication, accessKey, templateId);
        DBNodeParser dbLoader = new DBNodeParser(mNodeRegistry);
        return dbLoader.parser(dbContext, dblTemplate);
    }

    public IDBCoreView render(DBTemplate template, JsonObject extJsonObject, Context currentContext, Lifecycle lifecycle) {
        if (null != template) {
            template.setExtJsonObject(extJsonObject);
            template.setCurrentContext(currentContext);
            // 节点树解析
            template.parserAttribute();
            template.parserNode();
            template.finishParserNode();
            // 绑定生命周期
            template.bindLifecycle(lifecycle);
            return template.getDBCoreView();
        }
        return null;
    }

//    public boolean putProperties(String accessKey, DBTemplate template, Map properties) {
//        return true;
//    }
//
//    public boolean putProperty(String accessKey, DBTemplate template, String key, Object value) {
//        return true;
//    }
//
//    public boolean putGlobalProperties(String accessKey, Map properties) {
//        return true;
//    }

    public void putGlobalProperty(String accessKey, String key, String value) {
        DBGlobalPool.get(accessKey).addData(key, value);
    }

    public void putGlobalProperty(String accessKey, String key, int value) {
        DBGlobalPool.get(accessKey).addData(key, value);
    }

    public void putGlobalProperty(String accessKey, String key, boolean value) {
        DBGlobalPool.get(accessKey).addData(key, value);
    }

    public void registerDBNode(String nodeTag, INodeCreator nodeCreator) {
        mNodeRegistry.registerNode(nodeTag, nodeCreator);
    }

    private void initInternal() {
        registerRenderNode();
        registerActionNode(mNodeRegistry);
        registerOtherNode(mNodeRegistry);
    }

    private void registerRenderNode() {
        // 根节点
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBLView.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBLView.NodeCreator());
        // 辅助节点
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBChildren.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBChildren.NodeCreator());
        // 容器节点
        mNodeRegistry.registerNode(DBConstants.UI_ROOT, null);
        mNodeRegistry.registerNode(DBConstants.LAYOUT_TYPE_YOGA, null);
        mNodeRegistry.registerNode(DBConstants.LAYOUT_TYPE_FRAME, null);
        mNodeRegistry.registerNode(DBConstants.LAYOUT_TYPE_LINEAR, null);
        // 视图节点
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBView.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBView.NodeCreator());
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBText.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBText.NodeCreator());
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBImage.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBImage.NodeCreator());
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBButton.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBButton.NodeCreator());
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBLoading.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBLoading.NodeCreator());
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBProgress.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBProgress.NodeCreator());
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBList.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBList.NodeCreator());
        mNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.render.DBFlow.getNodeTag(),
                new com.didi.carmate.dreambox.core.render.DBFlow.NodeCreator());
    }

    private void registerActionNode(DBNodeRegistry nodeRegistry) {
        nodeRegistry.registerNode(DBClosePage.getNodeTag(), new DBClosePage.NodeCreator());
        nodeRegistry.registerNode(DBLog.getNodeTag(), new DBLog.NodeCreator());
        nodeRegistry.registerNode(DBTrace.getNodeTag(), new DBTrace.NodeCreator());
        nodeRegistry.registerNode(DBTraceAttr.getNodeTag(), new DBTraceAttr.NodeCreator());
        nodeRegistry.registerNode(DBActionAlias.getNodeTag(), new DBActionAlias.NodeCreator());
        nodeRegistry.registerNode(DBStorage.getNodeTag(), new DBStorage.NodeCreator());
        nodeRegistry.registerNode(DBChangeMeta.getNodeTag(), new DBChangeMeta.NodeCreator());
        nodeRegistry.registerNode(DBDialog.getNodeTag(), new DBDialog.NodeCreator());
        nodeRegistry.registerNode(DBNav.getNodeTag(), new DBNav.NodeCreator());
        nodeRegistry.registerNode(DBNet.getNodeTag(), new DBNet.NodeCreator());
        nodeRegistry.registerNode(DBToast.getNodeTag(), new DBToast.NodeCreator());
        nodeRegistry.registerNode(DBInvoke.getNodeTag(), new DBInvoke.NodeCreator());
        nodeRegistry.registerNode(DBActions.getNodeTag(), new DBActions.NodeCreator());
    }

    private void registerOtherNode(DBNodeRegistry nodeRegistry) {
        // bridge
        nodeRegistry.registerNode(DBSendEvent.getNodeTag(), new DBSendEvent.NodeCreator());
        nodeRegistry.registerNode(DBSendEventMsg.getVNodeTag(), new DBSendEventMsg.VNodeCreator());
        // meta
        nodeRegistry.registerNode(DBMeta.getNodeTag(), new DBMeta.NodeCreator());
        // callback
        nodeRegistry.registerNode(DBCallbacks.getNodeTag(), new DBCallbacks.NodeCreator());
    }
}
