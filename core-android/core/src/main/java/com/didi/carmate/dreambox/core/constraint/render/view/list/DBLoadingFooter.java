package com.didi.carmate.dreambox.core.constraint.render.view.list;

import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewStub;
import android.widget.TextView;

import com.didi.carmate.dreambox.core.R;
import com.didi.carmate.dreambox.core.base.DBContext;
import com.didi.carmate.dreambox.core.constraint.render.view.DBCircleLoading;
import com.didi.carmate.dreambox.core.constraint.render.view.DBConstraintView;

public class DBLoadingFooter extends DBConstraintView implements ILoadMoreFooter {

    protected State mState = State.Normal;
    private View mLoadingView;
    private View mNetworkErrorView;
    private View mTheEndView;
    private DBCircleLoading mProgressView;
    private TextView mLoadingText;
    private TextView mNoMoreText;
    private TextView mNoNetWorkText;
    private String loadingHint;
    private String noMoreHint;
    private String noNetWorkHint;

    public DBLoadingFooter(DBContext dbContext) {
        super(dbContext);
        init();
    }

    public DBLoadingFooter(DBContext dbContext, AttributeSet attrs) {
        super(dbContext, attrs);
        init();
    }

    public DBLoadingFooter(DBContext dbContext, AttributeSet attrs, int defStyleAttr) {
        super(dbContext, attrs, defStyleAttr);
        init();
    }

    public void init() {
        inflate(getContext(), R.layout.db_list_footer, this);
        setOnClickListener(null);

        onReset();//初始为隐藏状态
    }

    public void setLoadingHint(String hint) {
        this.loadingHint = hint;
    }

    public void setNoMoreHint(String hint) {
        this.noMoreHint = hint;
    }

    public void setNoNetWorkHint(String hint) {
        this.noNetWorkHint = hint;
    }

    public State getState() {
        return mState;
    }

    public void setState(State status) {
        setState(status, true);
    }

    @Override
    public void onReset() {
        onComplete();
    }

    @Override
    public void onLoading() {
        setState(State.Loading);
    }

    @Override
    public void onComplete() {
        setState(State.Normal);
    }

    @Override
    public void onNoMore() {
        setState(State.NoMore);
    }

    @Override
    public DBConstraintView getFootView() {
        return this;
    }

    @Override
    public void setNetworkErrorViewClickListener(final OnNetWorkErrorListener listener) {
        setState(State.NetWorkError);
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                setState(State.Loading);
                listener.reload();
            }
        });
    }

    @Override
    public void setOnClickLoadMoreListener(final OnLoadMoreListener listener) {
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                setState(State.Loading);
                listener.onLoadMore();
            }
        });
    }

    /**
     * 设置状态
     *
     * @param status   状态
     * @param showView 是否展示当前View
     */
    public void setState(State status, boolean showView) {
        if (mState == status) {
            return;
        }
        mState = status;

        switch (status) {
            case Normal:
                setOnClickListener(null);
                if (mLoadingView != null) {
                    mLoadingView.setVisibility(GONE);
                }

                if (mTheEndView != null) {
                    mTheEndView.setVisibility(GONE);
                }

                if (mNetworkErrorView != null) {
                    mNetworkErrorView.setVisibility(GONE);
                }

                break;
            case Loading:
                setOnClickListener(null);
                if (mTheEndView != null) {
                    mTheEndView.setVisibility(GONE);
                }

                if (mNetworkErrorView != null) {
                    mNetworkErrorView.setVisibility(GONE);
                }

                if (mLoadingView == null) {
                    ViewStub viewStub = findViewById(R.id.view_stub_loading);
                    mLoadingView = viewStub.inflate();

                    mProgressView = mLoadingView.findViewById(R.id.loading_progressbar);
                    mLoadingText = mLoadingView.findViewById(R.id.loading_text);
                }

                mLoadingView.setVisibility(showView ? VISIBLE : GONE);
                mProgressView.setVisibility(View.VISIBLE);
                mProgressView.setDrawable(R.drawable.db_loading_circle_anim);
                mLoadingText.setText(TextUtils.isEmpty(loadingHint) ? getResources().getString(R.string.list_footer_loading) : loadingHint);
                break;
            case NoMore:
                setOnClickListener(null);
                if (mLoadingView != null) {
                    mLoadingView.setVisibility(GONE);
                }

                if (mNetworkErrorView != null) {
                    mNetworkErrorView.setVisibility(GONE);
                }

                if (mTheEndView == null) {
                    ViewStub viewStub = findViewById(R.id.view_stub_end);
                    mTheEndView = viewStub.inflate();

                    mNoMoreText = mTheEndView.findViewById(R.id.loading_end_text);
                } else {
                    mTheEndView.setVisibility(VISIBLE);
                }

                mTheEndView.setVisibility(showView ? VISIBLE : GONE);
                mNoMoreText.setText(TextUtils.isEmpty(noMoreHint) ? getResources().getString(R.string.list_footer_end) : noMoreHint);
                break;
            case NetWorkError:
                if (mLoadingView != null) {
                    mLoadingView.setVisibility(GONE);
                }

                if (mTheEndView != null) {
                    mTheEndView.setVisibility(GONE);
                }

                if (mNetworkErrorView == null) {
                    ViewStub viewStub = findViewById(R.id.view_stub_network_error);
                    mNetworkErrorView = viewStub.inflate();
                    mNoNetWorkText = mNetworkErrorView.findViewById(R.id.network_error_text);
                } else {
                    mNetworkErrorView.setVisibility(VISIBLE);
                }

                mNetworkErrorView.setVisibility(showView ? VISIBLE : GONE);
                mNoNetWorkText.setText(TextUtils.isEmpty(noNetWorkHint) ? getResources().getString(R.string.list_footer_network_error) : noNetWorkHint);
                break;
            default:
                break;
        }
    }
}