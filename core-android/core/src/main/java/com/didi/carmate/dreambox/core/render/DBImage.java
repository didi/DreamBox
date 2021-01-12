package com.didi.carmate.dreambox.core.render;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;

import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.data.DBData;
import com.didi.carmate.dreambox.core.utils.DBLogger;
import com.didi.carmate.dreambox.core.utils.DBScreenUtils;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.didi.carmate.dreambox.core.base.DBBaseView;
import com.didi.carmate.dreambox.core.render.view.DBPatchDotNineView;
import com.didi.carmate.dreambox.wrapper.ImageLoader;
import com.didi.carmate.dreambox.wrapper.Wrapper;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 * <p>
 * 第三方可扩展此类，<T> 为第三方扩展时需提供给DBImage用的native对象，具体做法：
 * 第三方视图节点继承 DBImage 并覆写 onGetParentNativeView 方法并返回类型为 <T> 的对象即可
 */
public class DBImage<T extends View> extends DBBaseView<T> {
    private int maxWidth;
    private int maxHeight;

    protected String src;
    protected String srcType;
    protected String scaleType;

    protected DBImage(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    public void onParserAttribute(Map<String, String> attrs) {
        super.onParserAttribute(attrs);

        srcType = getString(attrs.get("srcType"));
    }

    @Override
    protected View onCreateView() {
        View view;
        if ("ninePatch".equals(srcType)) {
            view = new DBPatchDotNineView(mDBContext.getContext());
        } else {
            view = new ImageView(mDBContext.getContext());
        }
        return view;
    }

    @Override
    public void onAttributesBind(Map<String, String> attrs) {
        super.onAttributesBind(attrs);

        src = getString(attrs.get("src"));
        scaleType = getString(attrs.get("scaleType"));
        maxWidth = DBScreenUtils.processSize(mDBContext, attrs.get("maxWidth"), 0);
        maxHeight = DBScreenUtils.processSize(mDBContext, attrs.get("maxHeight"), 0);

        bindAttribute(getNativeView());
        loadImage(getNativeView());
    }

    @Override
    protected void onDataChanged(final String key, final Map<String, String> attrs) {
        mDBContext.observeDataPool(new DBData.IDataObserver() {
            @Override
            public void onDataChanged(String key) {
                DBLogger.d(mDBContext, "key: " + key);
                src = getString(attrs.get("src"));
                loadImage(getNativeView());
            }

            @Override
            public String getKey() {
                return key;
            }
        });
    }

    private void bindAttribute(View view) {
        if ("ninePatch".equals(srcType) && view instanceof DBPatchDotNineView) {
            DBPatchDotNineView ninePatchView = (DBPatchDotNineView) view;
            // maxWidth
            if (maxWidth != 0) {
                ninePatchView.setMaxWidth(maxWidth);
            }
            // maxHeight
            if (maxHeight != 0) {
                ninePatchView.setMaxHeight(maxHeight);
            }
        } else if (view instanceof ImageView) {
            ImageView imageView = (ImageView) view;
            if (maxWidth != 0 || maxHeight != 0) {
                imageView.setAdjustViewBounds(true);
            }
            // maxWidth
            if (maxWidth != 0) {
                imageView.setMaxWidth(maxWidth);
            }
            // maxHeight
            if (maxHeight != 0) {
                imageView.setMaxHeight(maxHeight);
            }

            // scaleType
            if ("crop".equals(scaleType)) {
                imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
            } else if ("inside".equals(scaleType)) {
                imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            } else if ("fitXY".equals(scaleType)) {
                imageView.setScaleType(ImageView.ScaleType.FIT_XY);
            }
        }
    }

    protected void loadImage(View view) {
        ImageLoader imageLoader = Wrapper.get(mDBContext.getAccessKey()).imageLoader();
        if (DBUtils.isEmpty(src)) {
            Wrapper.get(mDBContext.getAccessKey()).log().e("src is empty");
            return;
        }

        if ("ninePatch".equals(srcType) && view instanceof DBPatchDotNineView) {
            DBPatchDotNineView ninePatchView = (DBPatchDotNineView) view;
            imageLoader.load(src, ninePatchView);
        } else if (view instanceof ImageView) {
            ImageView imageView = (ImageView) view;
            if (src.startsWith("http")) {
                imageLoader.load(src, imageView);
            } else {
                Context context = mDBContext.getContext();
                int resId = context.getResources().getIdentifier(src, "drawable", context.getPackageName());
                imageView.setImageResource(resId);
            }
        }
    }

    public View getNativeView() {
        return null == onGetParentNativeView() ? mNativeView : onGetParentNativeView();
    }

    public static String getNodeTag() {
        return "image";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBImage<?> createNode(DBContext dbContext) {
            return new DBImage<>(dbContext);
        }
    }
}
