package com.didi.carmate.dreambox.core.v4.render;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.GradientDrawable;
import android.view.View;

import com.didi.carmate.dreambox.core.v4.base.DBBaseView;
import com.didi.carmate.dreambox.core.v4.base.DBBorderCorner;
import com.didi.carmate.dreambox.core.v4.base.DBConstants;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBModel;
import com.didi.carmate.dreambox.core.v4.base.INodeCreator;
import com.didi.carmate.dreambox.core.v4.render.view.DBRichView;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBView<T extends DBRichView> extends DBBaseView<T> {
    private String gradientColor; // 过渡颜色
    private String gradientOrientation; // 过渡色方向
    private final DBBorderCorner mBorderCorner;
    private final DBBorderCorner.DBViewOutline mClipOutline;

    private DBView(DBContext dbContext) {
        super(dbContext);

        mBorderCorner = new DBBorderCorner();
        mClipOutline = new DBBorderCorner.DBViewOutline();
    }

    @Override
    protected View onCreateView() {
        return new DBRichView(mDBContext.getContext(), mBorderCorner);
    }

    @Override
    public void onAttributesBind(Map<String, String> attrs, DBModel model) {
        super.onAttributesBind(attrs, model);

        gradientColor = getString(attrs.get("gradientColor"), model);
        gradientOrientation = getString(attrs.get("gradientOrientation"), model);

        doRender(getNativeView());
    }

    private void doRender(DBRichView richView) {
        // 覆写父类背景颜色
        richView.setBackgroundColor(Color.TRANSPARENT);

        richView.setRadius(radius);
        richView.setRoundRadius(radius, radiusLT, radiusRT, radiusRB, radiusLB);
        if (DBUtils.isColor(borderColor)) {
            richView.setBorderColor(Color.parseColor(borderColor));
        }
        if (borderWidth > 0) {
            richView.setBorderWidth(borderWidth);
        }
        mClipOutline.setClipOutline(radius);
        richView.clipOutline(mClipOutline);

        // 背景色
        int[] colors = null;
        boolean checkColorsOK = false;
        if (!DBUtils.isEmpty(gradientColor)) {
            // 过渡颜色
            String[] colorsStr = gradientColor.split("-");
            colors = new int[colorsStr.length];
            for (int i = 0; i < colorsStr.length; i++) {
                String color = colorsStr[i];
                if (!DBUtils.isColor(color)) {
                    break;
                } else {
                    colors[i] = Color.parseColor(color);
                }
                if (i == colorsStr.length - 1) {
                    checkColorsOK = true;
                }
            }
        }
        if (checkColorsOK) {
            GradientDrawable dynamicDrawable = new GradientDrawable();
            dynamicDrawable.setGradientType(GradientDrawable.LINEAR_GRADIENT);
            dynamicDrawable.setUseLevel(false);
            // 过渡方向
            if (DBConstants.STYLE_ORIENTATION_H.equals(gradientOrientation)) {
                dynamicDrawable.setOrientation(GradientDrawable.Orientation.LEFT_RIGHT);
            } else {
                dynamicDrawable.setOrientation(GradientDrawable.Orientation.BOTTOM_TOP);
            }
            // 过渡颜色
            dynamicDrawable.setColors(colors);
            richView.setBackground(dynamicDrawable);
        } else if (!DBUtils.isEmpty(backgroundColor)) {
            richView.setBackground(new ColorDrawable(Color.parseColor(backgroundColor)));
        } else {
            richView.setBackground(new ColorDrawable(Color.TRANSPARENT));
        }
    }

    public DBRichView getNativeView() {
        return null == onGetParentNativeView() ? (DBRichView) mNativeView : onGetParentNativeView();
    }

    public static String getNodeTag() {
        return "view";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBView<?> createNode(DBContext dbContext) {
            return new DBView<>(dbContext);
        }
    }
}
