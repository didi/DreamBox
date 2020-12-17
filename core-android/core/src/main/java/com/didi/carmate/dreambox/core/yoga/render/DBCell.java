package com.didi.carmate.dreambox.core.yoga.render;

import android.view.ViewGroup;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.yoga.base.DBContainer;
import com.didi.carmate.dreambox.core.yoga.render.view.DBYogaView;

/**
 * author: chenjing
 * date: 2020/10/26
 */
public class DBCell extends DBContainer<DBYogaView> {
    public DBCell(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public DBYogaView onCreateView() {
        DBYogaView rootView = new DBYogaView(mDBContext);
        ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        rootView.setLayoutParams(lp);
        return rootView;
    }

    public static String getNodeTag() {
        return "cell";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBCell createNode(DBContext dbContext) {
            return new DBCell(dbContext);
        }
    }
}
