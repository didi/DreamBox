package com.didi.carmate.dreambox.core.base;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.render.view.DBFrameLayoutView;
import com.didi.carmate.dreambox.core.render.view.DBLinearLayoutView;
import com.didi.carmate.dreambox.core.render.view.DBYogaLayoutView;
import com.didi.carmate.dreambox.core.utils.DBScreenUtils;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.facebook.yoga.YogaAlign;
import com.facebook.yoga.YogaEdge;
import com.facebook.yoga.YogaNode;

import java.util.Map;

import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_SELF_BASELINE;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_SELF_CENTER;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_SELF_END;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_SELF_START;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_SELF_STRETCH;

/**
 * author: chenjing
 * date: 2020/11/10
 */
public abstract class DBAbsView<V extends View> extends DBBindView {
    protected View mNativeView;
    // 通用属性
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

    // YogaLayout属性
    protected float flexGrow;
    protected float flexShrink;
    protected float flexBasis;
    protected float flexBasisPercent;
    protected String alignSelf;

    protected DBAbsView(DBContext dbContext) {
        super(dbContext);
    }

    protected abstract View onCreateView();

    protected V onGetParentNativeView() {
        return null;
    }

    public int getId() {
        return id;
    }

    public View getNativeView() {
        return mNativeView;
    }

    @CallSuper
    protected void onParseLayoutAttr(Map<String, String> attrs) {
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

        // YogaLayout属性
        String fg = attrs.get("flex-grow");
        if (DBUtils.isNumeric(fg)) {
            flexGrow = Float.parseFloat(fg);
        }
        String fs = attrs.get("flex-shrink");
        if (DBUtils.isNumeric(fs)) {
            flexShrink = Float.parseFloat(fs);
        }
        String fb = attrs.get("flex-basis");
        if (null != fb) {
            if (fb.endsWith("%")) {
                fb = fb.substring(0, fb.length() - 1);
                if (DBUtils.isNumeric(fb)) {
                    flexBasisPercent = Float.parseFloat(fb);
                }
            } else {
                flexBasis = DBScreenUtils.processSize(mDBContext, fb, 0);
            }
        }
        alignSelf = attrs.get("align-self");
    }

    @CallSuper
    protected void onAttributesBind(final Map<String, String> attrs) {
        // backgroundColor
        backgroundColor = getString(attrs.get("backgroundColor"));
        if (DBUtils.isColor(backgroundColor)) {
            mNativeView.setBackgroundColor(DBUtils.parseColor(this, backgroundColor));
        }
    }

    @CallSuper
    protected void onViewAdded(ViewGroup parentView) {
        if (parentView instanceof DBYogaLayoutView) {
            // YogaLayout
            bindAttributesInYogaLayout(parentView);
        } else if (parentView instanceof DBLinearLayoutView) {
            // LinearLayout
            bindAttributesInLinearLayout(parentView);
        } else if (parentView instanceof DBFrameLayoutView) {
            // FrameLayout
            bindAttributesInFrameLayout(parentView);
        }
    }

    private void bindAttributesInLinearLayout(ViewGroup parentView) {

    }

    private void bindAttributesInFrameLayout(ViewGroup parentView) {

    }

    private void bindAttributesInYogaLayout(ViewGroup parentView) {
        YogaNode node = ((DBYogaLayoutView) parentView).getYogaNodeForView(mNativeView);
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

        if (flexGrow != 0) {
            node.setFlexGrow(flexGrow);
        }
        if (flexShrink != 0) {
            node.setFlexShrink(flexShrink);
        }
        if (flexBasis != 0) {
            node.setFlexBasis(flexBasis);
        }
        if (flexBasisPercent != 0) {
            node.setFlexBasisPercent(flexBasisPercent);
        }
        if (null != alignSelf) {
            switch (alignSelf) {
                case ALIGN_SELF_START:
                    node.setAlignSelf(YogaAlign.FLEX_START);
                    break;
                case ALIGN_SELF_END:
                    node.setAlignSelf(YogaAlign.FLEX_END);
                    break;
                case ALIGN_SELF_CENTER:
                    node.setAlignSelf(YogaAlign.CENTER);
                    break;
                case ALIGN_SELF_STRETCH:
                    node.setAlignSelf(YogaAlign.STRETCH);
                    break;
                case ALIGN_SELF_BASELINE:
                    node.setAlignSelf(YogaAlign.BASELINE);
                    break;
            }
        }
    }
}
