package com.didi.carmate.dreambox.core.utils;

import android.content.Context;
import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.wrapper.Wrapper;

/**
 * author: chenjing
 * date: 2020/5/9
 */
public class DBScreenUtils {
    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    public static int px2dip(Context context, float pxValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
    }

    public static int processSize(DBContext dBContext, String strSize, int defaultSize) {
        int intSize = defaultSize;

        if (DBUtils.isEmpty(strSize)) {
            return defaultSize;
        } else if (strSize.equals(DBConstants.FILL_TYPE_WRAP)) {
            intSize = ViewGroup.LayoutParams.WRAP_CONTENT;
        } else if (strSize.equals(DBConstants.FILL_TYPE_FILL)) {
            intSize = ViewGroup.LayoutParams.MATCH_PARENT;
        } else {
            // [单位] 判断
            int startIdx = strSize.length() - 2;
            if (startIdx < 1) {
                Wrapper.get(dBContext.getAccessKey()).log().e("[size] error -> " + strSize);
                return defaultSize;
            }
            String unit = strSize.substring(startIdx);
            if (!unit.equals(DBConstants.UNIT_TYPE_DP) && !unit.equals(DBConstants.UNIT_TYPE_PX)) {
                Wrapper.get(dBContext.getAccessKey()).log().e("[unit] error -> " + strSize);
                return intSize;
            }
            // 数值判断
            String rawSize = strSize.substring(0, strSize.length() - 2);
            // 负数判断
            boolean isNegative = false;
            String size;
            if (!rawSize.startsWith("-")) {
                size = rawSize;
            } else {
                size = rawSize.substring(1);
                isNegative = true;
            }

            if (!DBUtils.isNumeric(size)) {
                Wrapper.get(dBContext.getAccessKey()).log().e("size error -> " + strSize);
                return intSize;
            }

            if (unit.equals(DBConstants.UNIT_TYPE_DP)) {
                intSize = DBScreenUtils.dip2px(dBContext.getContext(), Float.parseFloat(size));
            } else {
                intSize = Integer.parseInt(size);
            }
            if (isNegative) {
                intSize = -intSize;
            }
        }
        return intSize;
    }
}
