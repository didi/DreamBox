package com.didi.carmate.dreambox.core.layout.render;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.layout.base.DBContainer;
import com.didi.carmate.dreambox.core.layout.render.view.DBYogaLayoutView;
import com.facebook.yoga.YogaAlign;
import com.facebook.yoga.YogaFlexDirection;
import com.facebook.yoga.YogaJustify;
import com.facebook.yoga.YogaWrap;

import java.util.Map;

import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_CONTENT;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_CONTENT_CENTER;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_CONTENT_END;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_CONTENT_START;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_CONTENT_STRETCH;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_CONTENT_S_AROUND;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_CONTENT_S_BETWEEN;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_ITEMS;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_ITEMS_BASELINE;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_ITEMS_CENTER;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_ITEMS_END;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_ITEMS_START;
import static com.didi.carmate.dreambox.core.base.DBConstants.ALIGN_ITEMS_STRETCH;
import static com.didi.carmate.dreambox.core.base.DBConstants.FLEX_DIRECTION_C;
import static com.didi.carmate.dreambox.core.base.DBConstants.FLEX_DIRECTION_C_REVERSE;
import static com.didi.carmate.dreambox.core.base.DBConstants.FLEX_DIRECTION_R;
import static com.didi.carmate.dreambox.core.base.DBConstants.FLEX_DIRECTION_R_REVERSE;
import static com.didi.carmate.dreambox.core.base.DBConstants.FLEX_WRAP;
import static com.didi.carmate.dreambox.core.base.DBConstants.FLEX_WRAP_NO_W;
import static com.didi.carmate.dreambox.core.base.DBConstants.FLEX_WRAP_W;
import static com.didi.carmate.dreambox.core.base.DBConstants.FLEX_WRAP_W_REVERSE;
import static com.didi.carmate.dreambox.core.base.DBConstants.JUSTIFY_CONTENT;
import static com.didi.carmate.dreambox.core.base.DBConstants.JUSTIFY_CONTENT_CENTER;
import static com.didi.carmate.dreambox.core.base.DBConstants.JUSTIFY_CONTENT_END;
import static com.didi.carmate.dreambox.core.base.DBConstants.JUSTIFY_CONTENT_START;
import static com.didi.carmate.dreambox.core.base.DBConstants.JUSTIFY_CONTENT_S_AROUND;
import static com.didi.carmate.dreambox.core.base.DBConstants.JUSTIFY_CONTENT_S_BETWEEN;
import static com.didi.carmate.dreambox.core.base.DBConstants.JUSTIFY_CONTENT_S_EVENLY;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBYogaLayout extends DBContainer<ViewGroup> {
    private String flexDirection;
    private String flexWrap;
    private String justifyContent;
    private String alignItems;
    private String alignContent;

    public DBYogaLayout(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void onParseLayoutAttr(Map<String, String> attrs) {
        super.onParseLayoutAttr(attrs);

        flexDirection = attrs.get(DBConstants.FLEX_DIRECTION);
        flexWrap = attrs.get(FLEX_WRAP);
        justifyContent = attrs.get(JUSTIFY_CONTENT);
        alignItems = attrs.get(ALIGN_CONTENT);
        alignContent = attrs.get(ALIGN_ITEMS);
    }

    @Override
    protected void onAttributesBind(final Map<String, String> attrs) {
        super.onAttributesBind(attrs);

        final DBYogaLayoutView yoga = (DBYogaLayoutView) mNativeView;
        if (null != flexDirection) {
            switch (flexDirection) {
                case FLEX_DIRECTION_R:
                    yoga.getYogaNode().setFlexDirection(YogaFlexDirection.ROW);
                    break;
                case FLEX_DIRECTION_C:
                    yoga.getYogaNode().setFlexDirection(YogaFlexDirection.COLUMN);
                    break;
                case FLEX_DIRECTION_R_REVERSE:
                    yoga.getYogaNode().setFlexDirection(YogaFlexDirection.ROW_REVERSE);
                    break;
                case FLEX_DIRECTION_C_REVERSE:
                    yoga.getYogaNode().setFlexDirection(YogaFlexDirection.COLUMN_REVERSE);
                    break;
            }
        }
        if (null != flexWrap) {
            switch (flexWrap) {
                case FLEX_WRAP_W:
                    yoga.getYogaNode().setWrap(YogaWrap.WRAP);
                    break;
                case FLEX_WRAP_NO_W:
                    yoga.getYogaNode().setWrap(YogaWrap.NO_WRAP);
                    break;
                case FLEX_WRAP_W_REVERSE:
                    yoga.getYogaNode().setWrap(YogaWrap.WRAP_REVERSE);
                    break;
            }
        }
        if (null != justifyContent) {
            switch (justifyContent) {
                case JUSTIFY_CONTENT_START:
                    yoga.getYogaNode().setJustifyContent(YogaJustify.FLEX_START);
                    break;
                case JUSTIFY_CONTENT_END:
                    yoga.getYogaNode().setJustifyContent(YogaJustify.FLEX_END);
                    break;
                case JUSTIFY_CONTENT_CENTER:
                    yoga.getYogaNode().setJustifyContent(YogaJustify.CENTER);
                    break;
                case JUSTIFY_CONTENT_S_BETWEEN:
                    yoga.getYogaNode().setJustifyContent(YogaJustify.SPACE_BETWEEN);
                    break;
                case JUSTIFY_CONTENT_S_AROUND:
                    yoga.getYogaNode().setJustifyContent(YogaJustify.SPACE_AROUND);
                    break;
                case JUSTIFY_CONTENT_S_EVENLY:
                    yoga.getYogaNode().setJustifyContent(YogaJustify.SPACE_EVENLY);
                    break;
            }
        }
        if (null != alignItems) {
            switch (alignItems) {
                case ALIGN_ITEMS_START:
                    yoga.getYogaNode().setAlignItems(YogaAlign.FLEX_START);
                    break;
                case ALIGN_ITEMS_END:
                    yoga.getYogaNode().setAlignItems(YogaAlign.FLEX_END);
                    break;
                case ALIGN_ITEMS_CENTER:
                    yoga.getYogaNode().setAlignItems(YogaAlign.CENTER);
                    break;
                case ALIGN_ITEMS_STRETCH:
                    yoga.getYogaNode().setAlignItems(YogaAlign.STRETCH);
                    break;
                case ALIGN_ITEMS_BASELINE:
                    yoga.getYogaNode().setAlignItems(YogaAlign.BASELINE);
                    break;
            }
        }
        if (null != alignContent) {
            switch (alignContent) {
                case ALIGN_CONTENT_START:
                    yoga.getYogaNode().setAlignContent(YogaAlign.FLEX_START);
                    break;
                case ALIGN_CONTENT_END:
                    yoga.getYogaNode().setAlignContent(YogaAlign.FLEX_END);
                    break;
                case ALIGN_CONTENT_CENTER:
                    yoga.getYogaNode().setAlignContent(YogaAlign.CENTER);
                    break;
                case ALIGN_CONTENT_STRETCH:
                    yoga.getYogaNode().setAlignContent(YogaAlign.STRETCH);
                    break;
                case ALIGN_CONTENT_S_BETWEEN:
                    yoga.getYogaNode().setAlignContent(YogaAlign.SPACE_BETWEEN);
                    break;
                case ALIGN_CONTENT_S_AROUND:
                    yoga.getYogaNode().setAlignContent(YogaAlign.SPACE_AROUND);
                    break;
            }
        }
    }

    @Override
    public DBYogaLayoutView onCreateView() {
        return new DBYogaLayoutView(mDBContext);
    }
}
