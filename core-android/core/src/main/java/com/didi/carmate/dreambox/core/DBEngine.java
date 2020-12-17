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
import com.didi.carmate.dreambox.core.yoga.render.DBRender;
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
    private DBNodeRegistry mConstraintNodeRegistry;
    private DBNodeRegistry mYogaNodeRegistry;

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
        mConstraintNodeRegistry = new DBNodeRegistry();
        mYogaNodeRegistry = new DBNodeRegistry();
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

        DBNodeParser dbLoader;
        if (dblTemplate.contains("\"type\": \"yoga\"")) {
            dbLoader = new DBNodeParser(mYogaNodeRegistry);
        } else {
            dbLoader = new DBNodeParser(mConstraintNodeRegistry);
        }
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
        mConstraintNodeRegistry.registerNode(nodeTag, nodeCreator);
        mYogaNodeRegistry.registerNode(nodeTag, nodeCreator);
    }

    private void initInternal() {
        // 约束布局引擎
        registerRenderNode();
        registerActionNode(mConstraintNodeRegistry);
        registerOtherNode(mConstraintNodeRegistry);

        // yoga布局引擎
        registerYogaNode();
        registerActionNode(mYogaNodeRegistry);
        registerOtherNode(mYogaNodeRegistry);
    }

    private void registerRenderNode() {
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBLView.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBLView.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBRender.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBRender.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBView.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBView.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBText.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBText.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBImage.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBImage.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBButton.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBButton.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBLoading.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBLoading.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBProgress.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBProgress.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBList.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBList.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBListVh.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBListVh.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBListHeader.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBListHeader.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBListFooter.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBListFooter.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBFlow.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBFlow.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBChildren.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBChildren.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.base.DBPack.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.base.DBPack.NodeCreator());
        mConstraintNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.constraint.render.DBCell.getNodeTag(),
                new com.didi.carmate.dreambox.core.constraint.render.DBCell.NodeCreator());
    }

    private void registerYogaNode() {
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBLView.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBLView.NodeCreator());
        mYogaNodeRegistry.registerNode(
                DBRender.getNodeTag(),
                new DBRender.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBView.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBView.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBText.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBText.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBImage.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBImage.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBButton.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBButton.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBLoading.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBLoading.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBProgress.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBProgress.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBList.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBList.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBListVh.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBListVh.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBListHeader.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBListHeader.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBListFooter.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBListFooter.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBFlow.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBFlow.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBChildren.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBChildren.NodeCreator());
        mYogaNodeRegistry.registerNode(
                com.didi.carmate.dreambox.core.yoga.render.DBCell.getNodeTag(),
                new com.didi.carmate.dreambox.core.yoga.render.DBCell.NodeCreator());
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
