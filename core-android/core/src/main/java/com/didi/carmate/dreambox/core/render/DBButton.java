package com.didi.carmate.dreambox.core.render;

import android.graphics.Typeface;
import android.util.TypedValue;
import android.widget.Button;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.utils.DBUtils;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/11
 */
public class DBButton extends DBBaseText<Button> {
    private DBButton(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected Button onCreateView() {
        return new Button(mDBContext.getContext());
    }

    @Override
    public void onAttributesBind(Button selfView, Map<String, String> attrs) {
        super.onAttributesBind(selfView, attrs);

        doRender(selfView);
    }

    @Override
    protected void doRender(Button button) {
        super.doRender(button);

        // text
        if (!DBUtils.isEmpty(src)) {
            button.setText(src);
        }
        // color
        if (DBUtils.isColor(color)) {
            button.setTextColor(DBUtils.parseColor(this, color));
        }
        // size
        if (size != DBConstants.DEFAULT_SIZE_TEXT) {
            button.setTextSize(TypedValue.COMPLEX_UNIT_PX, size);
        }
        // style
        if (!DBUtils.isEmpty(style)) {
            if (style.equals(DBConstants.STYLE_TXT_NORMAL)) {
                button.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
            } else if (style.equals(DBConstants.STYLE_TXT_BOLD)) {
                button.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
            }
        }
    }

    public static String getNodeTag() {
        return "button";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBButton createNode(DBContext dbContext) {
            return new DBButton(dbContext);
        }
    }
}
