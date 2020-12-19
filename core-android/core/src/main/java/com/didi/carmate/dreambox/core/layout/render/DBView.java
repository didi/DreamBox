package com.didi.carmate.dreambox.core.layout.render;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.GradientDrawable;
import android.view.View;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.utils.DBScreenUtils;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.didi.carmate.dreambox.core.layout.base.DBBaseView;
import com.didi.carmate.dreambox.core.layout.render.view.DBRichView;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBView<T extends DBRichView> extends DBBaseView<T> {
    private String shape; // 绘制形状
    private int radius; // 圆角半径
    private int radiusLT; // 左上角圆角半径
    private int radiusRT; // 右上角圆角半径
    private int radiusRB; // 右下角圆角半径
    private int radiusLB; // 左下角圆角半径
    private int borderWidth; // 边框宽度
    private String borderColor; // 边框颜色
    private String gradientColor; // 过渡颜色
    private String gradientOrientation; // 过渡色方向

    private DBView(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected View onCreateView() {
        return new DBRichView(mDBContext.getContext());
    }

    @Override
    public void onAttributesBind(Map<String, String> attrs) {
        super.onAttributesBind(attrs);

        shape = attrs.get("shape");
        radius = DBScreenUtils.processSize(mDBContext, attrs.get("radius"), 0);
        radiusLT = DBScreenUtils.processSize(mDBContext, attrs.get("radiusLT"), 0);
        radiusRT = DBScreenUtils.processSize(mDBContext, attrs.get("radiusRT"), 0);
        radiusRB = DBScreenUtils.processSize(mDBContext, attrs.get("radiusRB"), 0);
        radiusLB = DBScreenUtils.processSize(mDBContext, attrs.get("radiusLB"), 0);
        borderWidth = DBScreenUtils.processSize(mDBContext, attrs.get("borderWidth"), 0);
        borderColor = getString(attrs.get("borderColor"));
        gradientColor = getString(attrs.get("gradientColor"));
        gradientOrientation = getString(attrs.get("gradientOrientation"));

        doRender(getNativeView());
    }

    private void doRender(DBRichView richView) {
        // 覆写父类背景颜色
        richView.setBackgroundColor(Color.TRANSPARENT);
        if (radius != 0) {
            richView.setRoundRadius(radius, radius, radius, radius);
        } else {
            richView.setRoundRadius(radiusLT, radiusRT, radiusRB, radiusLB);
        }
//        // pressed颜色
//        richView.setPressed(false);
//        richView.setCoverColor(Color.parseColor("#66AAAA"));
        // 边框宽度
        if (borderWidth > 0) {
            richView.setBorderWidth(borderWidth);
        }
        // 边框颜色
        if (DBUtils.isColor(borderColor)) {
            richView.setBorderColor(DBUtils.parseColor(this, borderColor));
        }
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
            richView.setImageDrawable(dynamicDrawable);
        } else if (!DBUtils.isEmpty(backgroundColor)) {
            richView.setImageDrawable(new ColorDrawable(Color.parseColor(backgroundColor)));
        } else {
            richView.setImageDrawable(new ColorDrawable(Color.TRANSPARENT));
        }

        // 形状
        if (DBConstants.STYLE_VIEW_SHAPE_CIRCLE.equals(shape)) {
            richView.setShape(DBRichView.SHAPE_CIRCLE);
        } else {
            richView.setShape(DBRichView.SHAPE_REC);
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
