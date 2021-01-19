package com.didi.carmate.dreambox.core.v4.render;

import android.graphics.Paint;
import android.graphics.Typeface;
import android.util.TypedValue;
import android.view.View;
import android.widget.TextView;

import com.didi.carmate.dreambox.core.v4.base.DBConstants;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
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
public class DBText<T extends TextView> extends DBBaseText<T> {
    private int minWidth;
    private int maxWidth;
    private int minHeight;
    private int maxHeight;

    protected DBText(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected View onCreateView() {
        return new TextView(mDBContext.getContext());
    }

    @Override
    public void onAttributesBind(Map<String, String> attrs) {
        super.onAttributesBind(attrs);

        minWidth = DBScreenUtils.processSize(mDBContext, attrs.get("minWidth"), 0);
        maxWidth = DBScreenUtils.processSize(mDBContext, attrs.get("maxWidth"), 0);
        minHeight = DBScreenUtils.processSize(mDBContext, attrs.get("minHeight"), 0);
        maxHeight = DBScreenUtils.processSize(mDBContext, attrs.get("maxHeight"), 0);
        bindAttribute();
    }

    @Override
    protected void bindAttribute() {
        super.bindAttribute();

        // text
        if (!DBUtils.isEmpty(src)) {
            src = src.replace("\\n", "\n");
            getNativeView().setText(src);
        }
        // color
        if (DBUtils.isColor(color)) {
            getNativeView().setTextColor(DBUtils.parseColor(this, color));
        }
        // size
        if (size != DBConstants.DEFAULT_SIZE_TEXT) {
            getNativeView().setTextSize(TypedValue.COMPLEX_UNIT_PX, size);
        }
        // style
        if (!DBUtils.isEmpty(style)) {
            getNativeView().getPaint().setFlags(0);  // 取消设置的的划线
            switch (style) {
                case DBConstants.STYLE_TXT_NORMAL:
                    getNativeView().setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                    break;
                case DBConstants.STYLE_TXT_BOLD:
                    getNativeView().setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                    break;
                case DBConstants.STYLE_TXT_ITALIC:
                    getNativeView().setTypeface(Typeface.defaultFromStyle(Typeface.ITALIC));
                    break;
                case DBConstants.STYLE_TXT_STRIKE:
                    getNativeView().getPaint().setFlags(Paint.STRIKE_THRU_TEXT_FLAG | Paint.ANTI_ALIAS_FLAG); //中划线
                    break;
                case DBConstants.STYLE_TXT_UNDERLINE:
                    getNativeView().getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG); //下划线
                    break;
            }
        }
        // minWidth
        if (minWidth != 0) {
            getNativeView().setMinWidth(minWidth);
        }
        // maxWidth
        if (maxWidth != 0) {
            getNativeView().setMaxWidth(maxWidth);
        }
        // minHeight
        if (minHeight != 0) {
            getNativeView().setMinHeight(minHeight);
        }
        // maxHeight
        if (maxHeight != 0) {
            getNativeView().setMaxHeight(maxHeight);
        }
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
