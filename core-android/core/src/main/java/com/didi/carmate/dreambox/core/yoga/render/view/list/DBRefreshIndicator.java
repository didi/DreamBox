package com.didi.carmate.dreambox.core.yoga.render.view.list;

import android.animation.ValueAnimator;
import android.content.Context;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.didi.carmate.dreambox.core.R;
import com.didi.carmate.dreambox.core.utils.DBThreadUtils;
import com.didi.carmate.dreambox.core.yoga.render.view.DBDotLoading;

/**
 * author: chenjing
 * date: 2020/7/1
 */
public class DBRefreshIndicator extends LinearLayout implements IRefreshIndicator {
    private static final int ROTATE_ANIM_DURATION = 180;

    private TextView refreshStatus;
    private ImageView refreshImage;
    private DBDotLoading refreshLoading;

    private Animation imageRotateUpAnim;
    private Animation imageRotateDownAnim;
    private int mMeasuredHeight;
    private int mState = STATE_DEFAULT;

    public DBRefreshIndicator(Context context) {
        super(context);
        initView();
    }

    public DBRefreshIndicator(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    private void initView() {
        // 设置默认宽填充父容器、高为0、margin为0、padding为0
        // 高度设为零，使刷新区域不可见，下拉时动态设置高度
        MarginLayoutParams lp = new LayoutParams(LayoutParams.MATCH_PARENT, 0);
        lp.setMargins(0, 0, 0, 0);
        setLayoutParams(lp);
        setPadding(0, 0, 0, 0);

        // 初始化高度设为0
        LayoutInflater.from(getContext()).inflate(R.layout.db_list_refresh_indicator_default, this);
        setGravity(Gravity.BOTTOM); // 内容贴底，拉下时刷新区域跟着向下；设置为[TOP]拉下时刷新区域固定在顶部

        refreshStatus = findViewById(R.id.txt_refresh_status);
        refreshImage = findViewById(R.id.image_refresh);
        refreshLoading = findViewById(R.id.loading_refresh);

        imageRotateUpAnim = new RotateAnimation(0.0f, -180.0f,
                Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);
        imageRotateUpAnim.setDuration(ROTATE_ANIM_DURATION);
        imageRotateUpAnim.setFillAfter(true);
        imageRotateDownAnim = new RotateAnimation(-180.0f, 0.0f,
                Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);
        imageRotateDownAnim.setDuration(ROTATE_ANIM_DURATION);
        imageRotateDownAnim.setFillAfter(true);

        measure(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        mMeasuredHeight = getMeasuredHeight();
    }

    @Override
    public void refreshFinish() {
        setState(STATE_FINISH);
        DBThreadUtils.runOnMain(new Runnable() {
            public void run() {
                reset();
            }
        }, 200);
    }

    @Override
    public View getHeaderView() {
        return this;
    }

    public void setVisibleHeight(int height) {
        if (height < 0) height = 0;
        ViewGroup.LayoutParams lp = getLayoutParams();
        lp.height = height;
        setLayoutParams(lp);
    }

    @Override
    public int getVisibleHeight() {
        ViewGroup.LayoutParams lp = getLayoutParams();
        return lp.height;
    }

    @Override
    public void onReset() {
        setState(STATE_DEFAULT);
    }

    @Override
    public void onPrepare() {
        setState(STATE_READY);
    }

    @Override
    public void onRefreshing() {
        setState(STATE_REFRESHING);
    }

    @Override
    public void onMove(float offSet, float sumOffSet) {
        int top = getTop();
        if (offSet > 0 && top == 0) {
            setVisibleHeight((int) offSet + getVisibleHeight());
        } else if (offSet < 0 && getVisibleHeight() > 0) {
            layout(getLeft(), 0, getRight(), getHeight()); //重新布局让header显示在顶端
            setVisibleHeight((int) offSet + getVisibleHeight());
        }
        if (mState <= STATE_READY) { // 未处于刷新状态，更新箭头
            if (getVisibleHeight() > mMeasuredHeight) {
                onPrepare();
            } else {
                onReset();
            }
        }
    }

    @Override
    public boolean onRelease() {
        boolean isOnRefresh = false;
        int height = getVisibleHeight();
        if (getVisibleHeight() > mMeasuredHeight && mState < STATE_REFRESHING) {
            setState(STATE_REFRESHING);
            isOnRefresh = true;
        }
        // refreshing and header isn't shown fully. do nothing.
        if (mState == STATE_REFRESHING && height > mMeasuredHeight) {
            smoothScrollTo(mMeasuredHeight);
        }
        if (mState != STATE_REFRESHING) {
            smoothScrollTo(0);
        }

        if (mState == STATE_REFRESHING) {
            int destHeight = mMeasuredHeight;
            smoothScrollTo(destHeight);
        }

        return isOnRefresh;
    }

    private void smoothScrollTo(int destHeight) {
        ValueAnimator animator = ValueAnimator.ofInt(getVisibleHeight(), destHeight);
        animator.setDuration(300).start();
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                setVisibleHeight((int) animation.getAnimatedValue());
            }
        });
        animator.start();
    }

    private void setState(int state) {
        if (state == mState) return;

        if (state == STATE_REFRESHING) { // 显示进度
            refreshImage.clearAnimation();
            refreshImage.setVisibility(View.INVISIBLE);
            refreshLoading.setVisibility(View.VISIBLE);
            smoothScrollTo(mMeasuredHeight);
        } else if (state == STATE_FINISH) {
            refreshImage.setVisibility(View.INVISIBLE);
            refreshLoading.setVisibility(View.INVISIBLE);
        } else { // 显示图片
            refreshImage.setVisibility(View.VISIBLE);
            refreshLoading.setVisibility(View.INVISIBLE);
        }

        switch (state) {
            case STATE_DEFAULT:
                if (mState == STATE_READY) {
                    refreshImage.startAnimation(imageRotateDownAnim);
                }
                if (mState == STATE_REFRESHING) {
                    refreshImage.clearAnimation();
                }
                refreshStatus.setText(R.string.list_refresh_area_default);
                break;
            case STATE_READY:
                if (mState != STATE_READY) {
                    refreshImage.clearAnimation();
                    refreshImage.startAnimation(imageRotateUpAnim);
                    refreshStatus.setText(R.string.list_refresh_area_ready);
                }
                break;
            case STATE_REFRESHING:
                refreshStatus.setText(R.string.list_refresh_area_refreshing);
                refreshLoading.startLoading();
                break;
            case STATE_FINISH:
                refreshStatus.setText(R.string.list_refresh_area_finish);
                refreshLoading.stopLoading();
                break;
            default:
        }

        mState = state;
    }

    private void reset() {
        smoothScrollTo(0);
        DBThreadUtils.runOnMain(new Runnable() {
            public void run() {
                setState(STATE_DEFAULT);
            }
        }, 500);
    }
}
