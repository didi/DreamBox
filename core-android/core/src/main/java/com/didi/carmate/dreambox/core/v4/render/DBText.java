package com.didi.carmate.dreambox.core.v4.render;

import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.View;

import com.didi.carmate.dreambox.core.v4.base.DBBorderCorner;
import com.didi.carmate.dreambox.core.v4.base.DBConstants;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBModel;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.didi.carmate.dreambox.core.v4.utils.DBScreenUtils;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 * <p>
 * 第三方可扩展此类，<T> 为第三方扩展时需提供给DBText用的native对象，具体做法：
 * 第三方视图节点继承 DBText 并覆写 onGetParentNativeView 方法并返回类型为 <T> 的对象即可
 */
public class DBText<T extends DBTextView> extends DBBaseText<T> {
    private int minWidth;
    private int maxWidth;
    private int minHeight;
    private int maxHeight;
    private final DBBorderCorner mBorderCorner;
    private final DBBorderCorner.DBViewOutline mClipOutline;

    protected DBText(DBContext dbContext) {
        super(dbContext);

        mBorderCorner = new DBBorderCorner();
        mClipOutline = new DBBorderCorner.DBViewOutline();
    }

    @Override
    protected View onCreateView() {
        return new DBTextView(mDBContext.getContext(), mBorderCorner);
    }

    @Override
    public void onAttributesBind(Map<String, String> attrs, DBModel model) {
        super.onAttributesBind(attrs, model);

        minWidth = DBScreenUtils.processSize(mDBContext, attrs.get("minWidth"), 0);
        maxWidth = DBScreenUtils.processSize(mDBContext, attrs.get("maxWidth"), 0);
        minHeight = DBScreenUtils.processSize(mDBContext, attrs.get("minHeight"), 0);
        maxHeight = DBScreenUtils.processSize(mDBContext, attrs.get("maxHeight"), 0);
        bindAttribute();
    }

    @Override
    protected void bindAttribute() {
        super.bindAttribute();

        DBTextView nativeView = (DBTextView) getNativeView();
        // text
        if (!DBUtils.isEmpty(src)) {
            src = src.replace("\\n", "\n");
            nativeView.setText(src);
        }
        // color
        if (DBUtils.isColor(color)) {
            nativeView.setTextColor(DBUtils.parseColor(this, color));
        }
        // size
        if (size != DBConstants.DEFAULT_SIZE_TEXT) {
            nativeView.setTextSize(TypedValue.COMPLEX_UNIT_PX, size);
        }
        // style
        if (!DBUtils.isEmpty(style)) {
            int paintFlags = nativeView.getPaintFlags();
            switch (style) {
                case DBConstants.STYLE_TXT_NORMAL:
                    nativeView.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                    break;
                case DBConstants.STYLE_TXT_BOLD:
                    nativeView.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                    break;
                case DBConstants.STYLE_TXT_ITALIC:
                    nativeView.setTypeface(Typeface.defaultFromStyle(Typeface.ITALIC));
                    break;
            }
            if (TextUtils.equals(style, DBConstants.STYLE_TXT_STRIKE)) {
                //中划线
                paintFlags |= Paint.STRIKE_THRU_TEXT_FLAG;
            } else {
                paintFlags &= ~Paint.STRIKE_THRU_TEXT_FLAG;
            }
            if (TextUtils.equals(style, DBConstants.STYLE_TXT_UNDERLINE)) {
                //下划线
                paintFlags |= Paint.UNDERLINE_TEXT_FLAG;
            } else {
                paintFlags &= ~Paint.UNDERLINE_TEXT_FLAG;
            }
            nativeView.setPaintFlags(paintFlags);
        }
        // minWidth
        if (minWidth != 0) {
            nativeView.setMinWidth(minWidth);
        }
        // maxWidth
        if (maxWidth != 0) {
            nativeView.setMaxWidth(maxWidth);
        }
        // minHeight
        if (minHeight != 0) {
            nativeView.setMinHeight(minHeight);
        }
        // maxHeight
        if (maxHeight != 0) {
            nativeView.setMaxHeight(maxHeight);
        }
        nativeView.setRadius(radius);
        nativeView.setRoundRadius(radius, radiusLT, radiusRT, radiusRB, radiusLB);
        if (DBUtils.isColor(borderColor)) {
            nativeView.setBorderColor(Color.parseColor(borderColor));
        }
        if (borderWidth > 0) {
            nativeView.setBorderWidth(borderWidth);
        }
        mClipOutline.setClipOutline(radius);
        nativeView.clipOutline(mClipOutline);
    }

    public static String getNodeTag() {
        return "text";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBText<?> createNode(DBContext dbContext) {
            return new DBText<>(dbContext);
        }
    }
}
