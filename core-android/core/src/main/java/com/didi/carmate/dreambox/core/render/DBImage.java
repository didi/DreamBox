package com.didi.carmate.dreambox.core.render;

import android.view.View;
import android.widget.ImageView;

import com.didi.carmate.dreambox.core.base.DBBaseView;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.base.INodeCreator;
import com.didi.carmate.dreambox.core.render.view.DBPatchDotNineView;
import com.didi.carmate.dreambox.core.utils.DBUtils;
import com.didi.carmate.dreambox.wrapper.ImageLoader;
import com.didi.carmate.dreambox.wrapper.Wrapper;

import java.util.Map;

/**
 * author: chenjing
 * date: 2020/4/30
 */
public class DBImage extends DBBaseView<View> {
    private String src;
    private String srcType;
    private String scaleType;

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
    public void onAttributesBind(View selfView, Map<String, String> attrs) {
        super.onAttributesBind(selfView, attrs);

        src = getString(attrs.get("src"));
        scaleType = getString(attrs.get("scaleType"));

        loadImage(selfView);
    }

    @Override
    public void changeOnCallback(View selfView, String key, String oldValue, String newValue) {
        if (null != newValue) {
            src = getString(newValue);

            loadImage(selfView);
        }
    }

    private void loadImage(View view) {
        ImageLoader imageLoader = Wrapper.get(mDBContext.getAccessKey()).imageLoader();

        if ("ninePatch".equals(srcType) && view instanceof DBPatchDotNineView) {
            DBPatchDotNineView ninePatchView = (DBPatchDotNineView) view;
            if (!DBUtils.isEmpty(src)) {
                imageLoader.load(src, ninePatchView);
            }
        } else if (view instanceof ImageView) {
            ImageView imageView = (ImageView) view;
            // scaleType
            if ("crop".equals(scaleType)) {
                imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
            } else if ("inside".equals(scaleType)) {
                imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            } else if ("fitXY".equals(scaleType)) {
                imageView.setScaleType(ImageView.ScaleType.FIT_XY);
            }
            // src
            if (!DBUtils.isEmpty(src)) {
                imageLoader.load(src, imageView);
            }
        }
    }

    public static String getNodeTag() {
        return "image";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public DBImage createNode(DBContext dbContext) {
            return new DBImage(dbContext);
        }
    }
}
