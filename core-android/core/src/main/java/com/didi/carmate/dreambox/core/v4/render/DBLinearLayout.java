package com.didi.carmate.dreambox.core.v4.render;

import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.didi.carmate.dreambox.core.v4.base.DBConstants;
import com.didi.carmate.dreambox.core.v4.base.DBContext;
import com.didi.carmate.dreambox.core.v4.base.DBContainer;
import com.didi.carmate.dreambox.core.v4.base.DBModel;
import com.didi.carmate.dreambox.core.v4.render.view.DBLinearLayoutView;
import com.didi.carmate.dreambox.core.v4.utils.DBUtils;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/5/7
 */
public class DBLinearLayout extends DBContainer<ViewGroup> {
    private int orientation;

    public DBLinearLayout(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public DBLinearLayoutView onCreateView() {
        return new DBLinearLayoutView(mDBContext);
    }

    @Override
    protected void onAttributesBind(Map<String, String> attrs, DBModel model) {
        super.onAttributesBind(attrs, model);

        String ot = attrs.get("orientation");
        if (DBUtils.isEmpty(ot)) {
            orientation = LinearLayout.HORIZONTAL;
        } else {
            orientation = DBConstants.STYLE_ORIENTATION_H.equals(ot) ? LinearLayout.HORIZONTAL : LinearLayout.VERTICAL;
        }
        DBLinearLayoutView linearLayoutView = (DBLinearLayoutView) getNativeView();
        linearLayoutView.setOrientation(orientation);
    }
}
