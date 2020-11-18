package com.didi.carmate.dreambox.core.render;

import android.graphics.Typeface;
import android.util.TypedValue;
import android.widget.TextView;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.utils.DBUtils;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBText extends DBBaseText<TextView> {
    protected DBText(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected TextView onCreateView() {
        return new TextView(mDBContext.getContext());
    }

    @Override
    public void onAttributesBind(TextView selfView, Map<String, String> attrs) {
        super.onAttributesBind(selfView, attrs);

        doRender(selfView);
    }

    @Override
    protected void doRender(TextView textView) {
        super.doRender(textView);

        // text
        if (!DBUtils.isEmpty(src)) {
            src = src.replace("\\n", "\n");
            textView.setText(src);
        }
        // color
        if (!DBUtils.isEmpty(color)) {
            textView.setTextColor(DBUtils.parseColor(this, color));
        }
        // size
        if (size != DBConstants.DEFAULT_SIZE_TEXT) {
            textView.setTextSize(TypedValue.COMPLEX_UNIT_PX, size);
        }
        // style
        if (!DBUtils.isEmpty(style)) {
            if (style.equals(DBConstants.STYLE_TXT_NORMAL)) {
                textView.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
            } else if (style.equals(DBConstants.STYLE_TXT_BOLD)) {
                textView.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
            }
        }
    }

    @Override
    public void changeOnCallback(TextView view, String key, String oldValue, String newValue) {
        if (null != newValue && null != view) {
            src = getString(newValue);
            view.setText(src);
        }
    }

    public static String getNodeTag() {
        return "text";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBText createNode(DBContext dbContext) {
            return new DBText(dbContext);
        }
    }
}
