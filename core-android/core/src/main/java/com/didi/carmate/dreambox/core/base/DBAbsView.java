package com.didi.carmate.dreambox.core.base;

import android.view.View;

import androidx.annotation.CallSuper;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.didi.carmate.dreambox.core.utils.DBScreenUtils;
import com.didi.carmate.dreambox.core.utils.DBUtils;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/11/10
 */
public abstract class DBAbsView<V extends View> extends DBBindView {
    protected V mNativeView;
    protected int id = DBConstants.DEFAULT_ID_VIEW;
    protected int width;
    protected int height;
    protected String backgroundColor; // 背景颜色

    private int leftToLeft = DBConstants.DEFAULT_ID_VIEW;
    private int leftToRight = DBConstants.DEFAULT_ID_VIEW;
    private int rightToRight = DBConstants.DEFAULT_ID_VIEW;
    private int rightToLeft = DBConstants.DEFAULT_ID_VIEW;
    private int topToTop = DBConstants.DEFAULT_ID_VIEW;
    private int topToBottom = DBConstants.DEFAULT_ID_VIEW;
    private int bottomToTop = DBConstants.DEFAULT_ID_VIEW;
    private int bottomToBottom = DBConstants.DEFAULT_ID_VIEW;
    private int marginTop;
    private int marginBottom;
    private int marginLeft;
    private int marginRight;
    private int paddingTop;
    private int paddingBottom;
    private int paddingLeft;
    private int paddingRight;

    protected DBAbsView(DBContext dbContext) {
        super(dbContext);
    }

    protected abstract V onCreateView();

    @CallSuper
    protected void onAttributesBind(V selfView, final Map<String, String> attrs) {
        // backgroundColor
        backgroundColor = getString(attrs.get("backgroundColor"));
        if (!DBUtils.isEmpty(backgroundColor)) {
            mNativeView.setBackgroundColor(DBUtils.parseColor(this, backgroundColor));
        }
    }

    public int getId() {
        return id;
    }

    public int getLeftToLeft() {
        return leftToLeft;
    }

    public int getRightToLeft() {
        return rightToLeft;
    }

    public int getTopToTop() {
        return topToTop;
    }

    public int getBottomToTop() {
        return bottomToTop;
    }

    protected void parseLayoutAttr(Map<String, String> attrs) {
        // 位置
        String ltl = attrs.get("leftToLeft");
        if (null != ltl) {
            leftToLeft = Integer.parseInt(ltl);
        }
        String ltr = attrs.get("leftToRight");
        if (null != ltr) {
            leftToRight = Integer.parseInt(ltr);
        }
        String rtr = attrs.get("rightToRight");
        if (null != rtr) {
            rightToRight = Integer.parseInt(rtr);
        }
        String rtl = attrs.get("rightToLeft");
        if (null != rtl) {
            rightToLeft = Integer.parseInt(rtl);
        }
        String ttt = attrs.get("topToTop");
        if (null != ttt) {
            topToTop = Integer.parseInt(ttt);
        }
        String ttb = attrs.get("topToBottom");
        if (null != ttb) {
            topToBottom = Integer.parseInt(ttb);
        }
        String btt = attrs.get("bottomToTop");
        if (null != btt) {
            bottomToTop = Integer.parseInt(btt);
        }
        String btb = attrs.get("bottomToBottom");
        if (null != btb) {
            bottomToBottom = Integer.parseInt(btb);
        }
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
        if (null != w && w.equals(DBConstants.FILL_TYPE_FILL)) {
            width = 0;
            leftToLeft = DBConstants.DEFAULT_ID_ROOT;
            rightToRight = DBConstants.DEFAULT_ID_ROOT;
        }
        String h = attrs.get("height");
        height = DBScreenUtils.processSize(mDBContext, h, DBConstants.DEFAULT_SIZE_WIDTH);
        if (null != h && h.equals(DBConstants.FILL_TYPE_FILL)) {
            height = 0;
            topToTop = DBConstants.DEFAULT_ID_ROOT;
            bottomToBottom = DBConstants.DEFAULT_ID_ROOT;
        }
    }

    protected void setPadding() {
        mNativeView.setPadding(
                paddingLeft == DBConstants.DEFAULT_SIZE_EDGE ? mNativeView.getPaddingLeft() : paddingLeft,
                paddingTop == DBConstants.DEFAULT_SIZE_EDGE ? mNativeView.getPaddingTop() : paddingTop,
                paddingRight == DBConstants.DEFAULT_SIZE_EDGE ? mNativeView.getPaddingRight() : paddingRight,
                paddingBottom == DBConstants.DEFAULT_SIZE_EDGE ? mNativeView.getPaddingBottom() : paddingBottom
        );
    }

    protected ConstraintLayout.LayoutParams getLayoutParams() {
        ConstraintLayout.LayoutParams lp = new ConstraintLayout.LayoutParams(width, height);
        // 位置
        if (leftToLeft != DBConstants.DEFAULT_ID_VIEW) {
            lp.leftToLeft = leftToLeft;
        }
        if (leftToRight != DBConstants.DEFAULT_ID_VIEW) {
            lp.leftToRight = leftToRight;
        }
        if (rightToRight != DBConstants.DEFAULT_ID_VIEW) {
            lp.rightToRight = rightToRight;
        }
        if (rightToLeft != DBConstants.DEFAULT_ID_VIEW) {
            lp.rightToLeft = rightToLeft;
        }
        if (topToTop != DBConstants.DEFAULT_ID_VIEW) {
            lp.topToTop = topToTop;
        }
        if (topToBottom != DBConstants.DEFAULT_ID_VIEW) {
            lp.topToBottom = topToBottom;
        }
        if (bottomToBottom != DBConstants.DEFAULT_ID_VIEW) {
            lp.bottomToBottom = bottomToBottom;
        }
        if (bottomToTop != DBConstants.DEFAULT_ID_VIEW) {
            lp.bottomToTop = bottomToTop;
        }
        // 边距
        lp.setMargins(marginLeft, marginTop, marginRight, marginBottom);

        return lp;
    }
}
