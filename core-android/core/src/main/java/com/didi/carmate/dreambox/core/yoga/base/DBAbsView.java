package com.didi.carmate.dreambox.core.yoga.base;

import android.view.Display;
import android.view.View;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.utils.DBScreenUtils;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;
import com.facebook.yoga.YogaDisplay;
import com.facebook.yoga.YogaEdge;
import com.facebook.yoga.YogaNode;
import com.facebook.yoga.YogaPositionType;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/11/10
 */
public abstract class DBAbsView<V extends View> extends DBBindView {
    protected View mNativeView;
    protected int id = DBConstants.DEFAULT_ID_VIEW;
    protected int width;
    protected int height;
    protected String backgroundColor; // 背景颜色

    protected int marginTop;
    protected int marginBottom;
    protected int marginLeft;
    protected int marginRight;
    protected int paddingTop;
    protected int paddingBottom;
    protected int paddingLeft;
    protected int paddingRight;

    protected DBAbsView(DBContext dbContext) {
        super(dbContext);
    }

    protected abstract View onCreateView();

    protected V onGetParentNativeView() {
        return null;
    }

    @CallSuper
    protected void onAttributesBind(final Map<String, String> attrs) {
        // backgroundColor
        backgroundColor = getString(attrs.get("backgroundColor"));
        if (DBUtils.isColor(backgroundColor)) {
            mNativeView.setBackgroundColor(DBUtils.parseColor(this, backgroundColor));
        }
    }

    public int getId() {
        return id;
    }

    protected void parseLayoutAttr(Map<String, String> attrs) {
        // 边距
        String ml = attrs.get("marginLeft");
        marginLeft = DBScreenUtils.processSize(mDBContext, ml, DBConstants.DEFAULT_SIZE_EDGE);
        String mt = attrs.get("marginTop");
        marginTop = DBScreenUtils.processSize(mDBContext, mt, DBConstants.DEFAULT_SIZE_EDGE);
        String mr = attrs.get("marginRight");
        marginRight = DBScreenUtils.processSize(mDBContext, mr, DBConstants.DEFAULT_SIZE_EDGE);
        String mb = attrs.get("marginBottom");
        marginBottom = DBScreenUtils.processSize(mDBContext, mb, DBConstants.DEFAULT_SIZE_EDGE);
        // padding
        String pl = attrs.get("paddingLeft");
        paddingLeft = DBScreenUtils.processSize(mDBContext, pl, DBConstants.DEFAULT_SIZE_EDGE);
        String pt = attrs.get("paddingTop");
        paddingTop = DBScreenUtils.processSize(mDBContext, pt, DBConstants.DEFAULT_SIZE_EDGE);
        String pr = attrs.get("paddingRight");
        paddingRight = DBScreenUtils.processSize(mDBContext, pr, DBConstants.DEFAULT_SIZE_EDGE);
        String pb = attrs.get("paddingBottom");
        paddingBottom = DBScreenUtils.processSize(mDBContext, pb, DBConstants.DEFAULT_SIZE_EDGE);

        // 宽高
        String w = attrs.get("width");
        width = DBScreenUtils.processSize(mDBContext, w, DBConstants.DEFAULT_SIZE_WIDTH);
        String h = attrs.get("height");
        height = DBScreenUtils.processSize(mDBContext, h, DBConstants.DEFAULT_SIZE_HEIGHT);
    }

    protected void setMargin(DBYogaView yogaView) {
        YogaNode node = yogaView.getYogaNodeForView(mNativeView);
        if (marginLeft != DBConstants.DEFAULT_SIZE_EDGE) {
            node.setMargin(YogaEdge.LEFT, marginLeft);
        }
        if (marginTop != DBConstants.DEFAULT_SIZE_EDGE) {
            node.setMargin(YogaEdge.TOP, marginTop);
        }
        if (marginRight != DBConstants.DEFAULT_SIZE_EDGE) {
            node.setMargin(YogaEdge.RIGHT, marginRight);
        }
        if (marginBottom != DBConstants.DEFAULT_SIZE_EDGE) {
            node.setMargin(YogaEdge.BOTTOM, marginBottom);
        }
    }

    protected void setPadding(DBYogaView yogaView) {
        YogaNode node = yogaView.getYogaNodeForView(mNativeView);
        if (paddingLeft != DBConstants.DEFAULT_SIZE_EDGE) {
            node.setPadding(YogaEdge.LEFT, paddingLeft);
        }
        if (paddingTop != DBConstants.DEFAULT_SIZE_EDGE) {
            node.setPadding(YogaEdge.TOP, paddingTop);
        }
        if (paddingRight != DBConstants.DEFAULT_SIZE_EDGE) {
            node.setPadding(YogaEdge.RIGHT, paddingRight);
        }
        if (paddingBottom != DBConstants.DEFAULT_SIZE_EDGE) {
            node.setPadding(YogaEdge.BOTTOM, paddingBottom);
        }
    }
}
