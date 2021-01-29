package com.didi.carmate.dreambox.core.v4.render;

import android.graphics.Color;
import android.view.View;

import com.didi.carmate.dreambox.core.v4.R;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBModel;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;
import com.didi.carmate.dreambox.core.v4.base.DBBaseView;
import com.didi.carmate.dreambox.core.v4.render.view.DBCircleLoading;
import com.didi.carmate.dreambox.core.v4.render.view.DBDotLoading;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/11
 */
public class DBLoading extends DBBaseView<View> {
    private String style;

    private DBLoading(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        style = attrs.get("style");
    }

    @Override
    protected View onCreateView() {
        View view;
        if (DBUtils.isEmpty(style) || "circle".equals(style)) {
            view = new DBCircleLoading(mDBContext.getContext());
        } else {
            view = new DBDotLoading(mDBContext.getContext());
        }
        return view;
    }

    @Override
    public void onAttributesBind(Map<String, String> attrs, DBModel model) {
        super.onAttributesBind(attrs, model);

        doRender();
    }

    private void doRender() {
        if ((DBUtils.isEmpty(style) || "circle".equals(style)) && mNativeView instanceof DBCircleLoading) {
            DBCircleLoading progress = (DBCircleLoading) mNativeView;
            progress.setDrawable(R.drawable.db_loading_circle_anim);
        } else {
            DBDotLoading progress = (DBDotLoading) mNativeView;
            progress.setBgColor(Color.GREEN);
            progress.startLoading();
        }
    }

    public static String getNodeTag() {
        return "loading";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBLoading createNode(DBContext dbContext) {
            return new DBLoading(dbContext);
        }
    }
}
