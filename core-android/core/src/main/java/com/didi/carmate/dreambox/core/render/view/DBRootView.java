package com.didi.carmate.dreambox.core.render.view;

import android.util.AttributeSet;

import androidx.constraintlayout.solver.widgets.ConstraintWidget;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;

import com.didi.carmate.dreambox.core.base.DBBaseView;
import com.didi.carmate.dreambox.core.base.DBConstants;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.IDBNode;
import com.didi.carmate.dreambox.core.render.DBRender;
import com.didi.carmate.dreambox.core.render.IDBRender;
import com.didi.carmate.dreambox.core.utils.DBLogger;

import java.util.ArrayList;
import java.util.List;

/**
 * author: chenjing
 * date: 2020/5/22
 */
public class DBRootView extends ConstraintLayout {
    private final DBContext mDBContext;

    public DBRootView(DBContext dbContext) {
        super(dbContext.getContext(), null);
        mDBContext = dbContext;
    }

    public DBRootView(DBContext dbContext, AttributeSet attrs) {
        super(dbContext.getContext(), attrs);
        mDBContext = dbContext;
    }

    public DBRootView(DBContext dbContext, AttributeSet attrs, int defStyleAttr) {
        super(dbContext.getContext(), attrs, defStyleAttr);
        mDBContext = dbContext;
    }

    public void onRenderFinish(IDBRender dbRender) {
        // chain 处理
        List<IDBNode> children;
        if (dbRender instanceof DBRender) {
            children = dbRender.getChildren();
        } else {
            children = dbRender.getChildren().get(0).getChildren();
        }
        if (children.size() == 0) {
            DBLogger.e(mDBContext, "childNotes is empty.");
            return;
        }

        List<DBBaseView<?>> chainHeader = getChainHeaders(children);
        if (chainHeader.size() == 0) {
            DBLogger.d(mDBContext, "chain header is empty.");
            return;
        }

        List<DBChain> listChain = new ArrayList<>();
        for (DBBaseView<?> header : chainHeader) {
            listChain.add(getDBChain(header));
        }
        if (listChain.size() == 0) {
            DBLogger.d(mDBContext, "chain is empty.");
            return;
        }

        for (DBChain chain : listChain) {
            ConstraintSet constraintSet = new ConstraintSet();
            constraintSet.clone(this);
            if (chain.chainOrientation == DBChain.CHAIN_ORIENTATION_H) {
                constraintSet.setHorizontalChainStyle(chain.id, chain.chainType);
            } else if (chain.chainOrientation == DBChain.CHAIN_ORIENTATION_V) {
                constraintSet.setVerticalChainStyle(chain.id, chain.chainType);
            }
            constraintSet.applyTo(this);
        }
    }

    private List<DBBaseView<?>> getChainHeaders(List<IDBNode> childNodes) {
        List<DBBaseView<?>> chainHeader = new ArrayList<>();
        if (null != childNodes) {
            for (int i = 0; i < childNodes.size(); i++) {
                IDBNode dbNote = childNodes.get(i);
                if (dbNote instanceof DBBaseView) {
                    DBBaseView<?> dbBaseView = (DBBaseView<?>) dbNote;
                    String chainStyle = dbBaseView.getChainStyle();
                    if (DBConstants.STYLE_CHAIN_SPREAD.equals(chainStyle) ||
                            DBConstants.STYLE_CHAIN_SPREAD_INSIDE.equals(chainStyle) ||
                            DBConstants.STYLE_CHAIN_PACKED.equals(chainStyle)) {
                        IDBNode nextNode = childNodes.get(i + 1);
                        if (nextNode instanceof DBBaseView) {
                            dbBaseView.setNextNode((DBBaseView<?>) nextNode);
                        }
                        chainHeader.add(dbBaseView);
                    }
                }
            }
        }
        return chainHeader;
    }

    private DBChain getDBChain(DBBaseView<?> header) {
        DBChain dbChain = new DBChain();
        dbChain.id = header.getId();
        dbChain.chainType = convertChainType(header.getChainStyle());
        // chain方向判断
        DBBaseView<?> next = header.getNextNode();
        int leftToLeft = header.getLeftToLeft();
        int rightToLeft = header.getRightToLeft();
        int topToTop = header.getTopToTop();
        int bottomToTop = header.getBottomToTop();
        int nextId = next.getId();
        if (leftToLeft != DBConstants.DEFAULT_ID_VIEW && rightToLeft != DBConstants.DEFAULT_ID_VIEW && rightToLeft == nextId) {
            dbChain.chainOrientation = DBChain.CHAIN_ORIENTATION_H;
        } else if (topToTop != DBConstants.DEFAULT_ID_VIEW && bottomToTop != DBConstants.DEFAULT_ID_VIEW && bottomToTop == nextId) {
            dbChain.chainOrientation = DBChain.CHAIN_ORIENTATION_V;
        }
        return dbChain;
    }

    private int convertChainType(String chainStyle) {
        int chainType = ConstraintWidget.UNKNOWN;
        if (DBConstants.STYLE_CHAIN_SPREAD.equals(chainStyle)) {
            chainType = ConstraintWidget.CHAIN_SPREAD;
        } else if (DBConstants.STYLE_CHAIN_SPREAD_INSIDE.equals(chainStyle)) {
            chainType = ConstraintWidget.CHAIN_SPREAD_INSIDE;
        } else if (DBConstants.STYLE_CHAIN_PACKED.equals(chainStyle)) {
            chainType = ConstraintWidget.CHAIN_PACKED;
        }
        return chainType;
    }

    private static final class DBChain {
        static final int CHAIN_ORIENTATION_H = 1;
        static final int CHAIN_ORIENTATION_V = 2;

        int chainOrientation = 0;
        int id;
        int chainType = 0;
    }
}
