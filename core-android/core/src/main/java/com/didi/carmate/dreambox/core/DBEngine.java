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
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.DBNodeParser;
import com.didi.carmate.dreambox.core.base.DBNodeRegistry;
import com.didi.carmate.dreambox.core.base.DBPack;
import com.didi.carmate.dreambox.core.base.DBTemplate;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.bridge.DBSendEvent;
import com.didi.carmate.dreambox.core.bridge.DBSendEventCallback;
import com.didi.carmate.dreambox.core.bridge.DBSendEventMsg;
import com.didi.carmate.dreambox.core.base.DBCallbacks;
import com.didi.carmate.dreambox.core.data.DBGlobalPool;
import com.didi.carmate.dreambox.core.data.DBMeta;
import com.didi.carmate.dreambox.core.render.DBButton;
import com.didi.carmate.dreambox.core.render.DBCell;
import com.didi.carmate.dreambox.core.render.DBChildren;
import com.didi.carmate.dreambox.core.render.DBFlow;
import com.didi.carmate.dreambox.core.render.DBImage;
import com.didi.carmate.dreambox.core.render.DBLView;
import com.didi.carmate.dreambox.core.render.DBList;
import com.didi.carmate.dreambox.core.render.DBListFooter;
import com.didi.carmate.dreambox.core.render.DBListHeader;
import com.didi.carmate.dreambox.core.render.DBListVh;
import com.didi.carmate.dreambox.core.render.DBLoading;
import com.didi.carmate.dreambox.core.render.DBProgress;
import com.didi.carmate.dreambox.core.render.DBRender;
import com.didi.carmate.dreambox.core.render.DBText;
import com.didi.carmate.dreambox.core.render.DBView;
import com.didi.carmate.dreambox.core.render.view.IDBCoreView;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

/**
 * author: chenjing
 * date: 2020/5/6
 */
public class DBEngine {
    private static volatile DBEngine sInstance;

    private Application mApplication;
    private DBNodeParser mDBLoader;

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
        mDBLoader = new DBNodeParser();
        initInternal();
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
        return mDBLoader.parser(dbContext, dblTemplate);
    }

    public IDBCoreView render(DBTemplate template, JsonObject extJsonObject, Context currentContext, Lifecycle lifecycle) {
        if (null != template) {
            template.setExtJsonObject(extJsonObject);
            template.setCurrentContext(currentContext);
            // 节点树解析
            template.parserAttribute();
            template.parserNode();
            template.attributesBind();
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
        DBNodeRegistry.registerNode(nodeTag, nodeCreator);
    }

    private void initInternal() {
        registerRenderNode();
        registerActionNode();
        registerOtherNode();
    }

    private void registerRenderNode() {
        DBNodeRegistry.registerNode(DBLView.getNodeTag(), new DBLView.NodeCreator());
        DBNodeRegistry.registerNode(DBRender.getNodeTag(), new DBRender.NodeCreator());
        DBNodeRegistry.registerNode(DBView.getNodeTag(), new DBView.NodeCreator());
        DBNodeRegistry.registerNode(DBText.getNodeTag(), new DBText.NodeCreator());
        DBNodeRegistry.registerNode(DBImage.getNodeTag(), new DBImage.NodeCreator());
        DBNodeRegistry.registerNode(DBButton.getNodeTag(), new DBButton.NodeCreator());
        DBNodeRegistry.registerNode(DBLoading.getNodeTag(), new DBLoading.NodeCreator());
        DBNodeRegistry.registerNode(DBProgress.getNodeTag(), new DBProgress.NodeCreator());
        DBNodeRegistry.registerNode(DBList.getNodeTag(), new DBList.NodeCreator());
        DBNodeRegistry.registerNode(DBListVh.getNodeTag(), new DBListVh.NodeCreator());
        DBNodeRegistry.registerNode(DBListHeader.getNodeTag(), new DBListHeader.NodeCreator());
        DBNodeRegistry.registerNode(DBListFooter.getNodeTag(), new DBListFooter.NodeCreator());
        DBNodeRegistry.registerNode(DBFlow.getNodeTag(), new DBFlow.NodeCreator());
        DBNodeRegistry.registerNode(DBChildren.getNodeTag(), new DBChildren.NodeCreator());
        DBNodeRegistry.registerNode(DBPack.getNodeTag(), new DBPack.NodeCreator());
        DBNodeRegistry.registerNode(DBCell.getNodeTag(), new DBCell.NodeCreator());
    }

    private void registerActionNode() {
        DBNodeRegistry.registerNode(DBClosePage.getNodeTag(), new DBClosePage.NodeCreator());
        DBNodeRegistry.registerNode(DBLog.getNodeTag(), new DBLog.NodeCreator());
        DBNodeRegistry.registerNode(DBTrace.getNodeTag(), new DBTrace.NodeCreator());
        DBNodeRegistry.registerNode(DBTraceAttr.getNodeTag(), new DBTraceAttr.NodeCreator());
        DBNodeRegistry.registerNode(DBActionAlias.getNodeTag(), new DBActionAlias.NodeCreator());
        DBNodeRegistry.registerNode(DBStorage.getNodeTag(), new DBStorage.NodeCreator());
        DBNodeRegistry.registerNode(DBChangeMeta.getNodeTag(), new DBChangeMeta.NodeCreator());
        DBNodeRegistry.registerNode(DBDialog.getNodeTag(), new DBDialog.NodeCreator());
        DBNodeRegistry.registerNode(DBNav.getNodeTag(), new DBNav.NodeCreator());
        DBNodeRegistry.registerNode(DBNet.getNodeTag(), new DBNet.NodeCreator());
        DBNodeRegistry.registerNode(DBToast.getNodeTag(), new DBToast.NodeCreator());
        DBNodeRegistry.registerNode(DBInvoke.getNodeTag(), new DBInvoke.NodeCreator());
        DBNodeRegistry.registerNode(DBActions.getNodeTag(), new DBActions.NodeCreator());
    }

    private void registerOtherNode() {
        // bridge
        DBNodeRegistry.registerNode(DBSendEvent.getNodeTag(), new DBSendEvent.NodeCreator());
        DBNodeRegistry.registerNode(DBSendEventMsg.getVNodeTag(), new DBSendEventMsg.VNodeCreator());
        DBNodeRegistry.registerNode(DBSendEventCallback.getNodeTag(), new DBSendEventCallback.NodeCreator());
        // meta
        DBNodeRegistry.registerNode(DBMeta.getNodeTag(), new DBMeta.NodeCreator());
        // callback
        DBNodeRegistry.registerNode(DBCallbacks.getNodeTag(), new DBCallbacks.NodeCreator());
    }
}
