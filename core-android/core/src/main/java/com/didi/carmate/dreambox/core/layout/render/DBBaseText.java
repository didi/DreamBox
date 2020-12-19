package com.didi.carmate.dreambox.core.layout.render;

import android.text.TextUtils;
import android.view.Gravity;
import android.widget.TextView;

import androidx.annotation.CallSuper;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.data.DBData;
import com.didi.carmate.dreambox.core.utils.DBLogger;
import com.didi.carmate.dreambox.core.utils.DBScreenUtils;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.didi.carmate.dreambox.core.layout.base.DBBaseView;

import java.util.HashMap;
import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public abstract class DBBaseText<V extends TextView> extends DBBaseView<V> {
    private final Map<String, Integer> mapGravity = new HashMap<>();

    protected String src;
    protected int size;
    protected String color;
    protected String style;
    protected int gravity;
    protected TextUtils.TruncateAt ellipsize;
    protected int maxLines;

    protected DBBaseText(DBContext dbContext) {
        super(dbContext);

        mapGravity.put(DBConstants.STYLE_GRAVITY_LEFT, Gravity.START);
        mapGravity.put(DBConstants.STYLE_GRAVITY_RIGHT, Gravity.END);
        mapGravity.put(DBConstants.STYLE_GRAVITY_TOP, Gravity.TOP);
        mapGravity.put(DBConstants.STYLE_GRAVITY_BOTTOM, Gravity.BOTTOM);
        mapGravity.put(DBConstants.STYLE_GRAVITY_CENTER, Gravity.CENTER);
    }

    @Override
    public void onAttributesBind(Map<String, String> attrs) {
        super.onAttributesBind(attrs);

        src = getString(attrs.get("src"));
        String rawSizePool = getString(attrs.get("size"));
        size = DBScreenUtils.processSize(mDBContext, rawSizePool, DBConstants.DEFAULT_SIZE_TEXT);
        color = getString(attrs.get("color"));
        style = getString(attrs.get("style"));
        gravity = convertGravity(attrs.get("gravity"));
        String rawEllipsize = attrs.get("ellipsize");
        if (null != rawEllipsize) {
            ellipsize = convertEllipsize(rawEllipsize);
        }
        String rawMaxLines = attrs.get("maxLines");
        if (DBUtils.isNumeric(rawMaxLines)) {
            maxLines = Integer.parseInt(rawMaxLines);
        }
    }

    @Override
    protected void onDataChanged(final String key, final Map<String, String> attrs) {
        mDBContext.observeDataPool(new DBData.IDataObserver() {
            @Override
            public void onDataChanged(String key) {
                DBLogger.d(mDBContext, "key: " + key);
                if (null != getNativeView()) {
                    src = getString(attrs.get("src"));
                    getNativeView().setText(src);
                }
            }

            @Override
            public String getKey() {
                return key;
            }
        });
    }

    @CallSuper
    protected void bindAttribute() {
        // gravity
        if (gravity != 0) {
            getNativeView().setGravity(gravity);
        }
        if (null != ellipsize) {
            getNativeView().setEllipsize(ellipsize);
        }
        if (maxLines > 0) {
            getNativeView().setMaxLines(maxLines);
        }
    }

    public TextView getNativeView() {
        return null == onGetParentNativeView() ? (TextView) mNativeView : onGetParentNativeView();
    }

    private TextUtils.TruncateAt convertEllipsize(String ellipsize) {
        switch (ellipsize) {
            case "start":
                return TextUtils.TruncateAt.START;
            case "middle":
                return TextUtils.TruncateAt.MIDDLE;
            case "end":
                return TextUtils.TruncateAt.END;
        }
        return null;
    }

    private int convertGravity(String gravity) {
        if (null == gravity) {
            return 0;
        }
        String[] gravityArr = gravity.split("\\|");
        int iGravity = 0;
        for (String strGravity : gravityArr) {
            Integer tmp = mapGravity.get(strGravity);
            if (null != tmp) {
                iGravity |= tmp;
            }
        }
        return iGravity;
    }
}
