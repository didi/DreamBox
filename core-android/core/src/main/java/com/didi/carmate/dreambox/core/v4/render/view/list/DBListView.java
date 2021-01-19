package com.didi.carmate.dreambox.core.v4.render.view.list;

import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.didi.carmate.dreambox.core.v4.base.DBContext;

/**
 * author: chenjing
 * date: 2020/6/30
 */
public class DBListView extends RecyclerView {
    private boolean mPullRefreshEnabled = false;
    private boolean mLoadMoreEnabled = false;
    private boolean mRefreshing = false;//是否正在下拉刷新
    private boolean mLoadingData = false;//是否正在加载数据
    private IRefreshListener mRefreshListener;
    private OnLoadMoreListener mLoadMoreListener;
    private LScrollListener mLScrollListener;
    private IRefreshIndicator mRefreshHeader;
    private ILoadMoreFooter mLoadMoreFooter;
    private View mEmptyView;
    private ViewGroup mLoaderView;

    private final AdapterDataObserver mDataObserver = new DataObserver();
    private int mActivePointerId;
    private float mLastY = -1;
    private float sumOffSet;
    private static final float DRAG_RATE = 2.0f;
    private int mPageSize = 10; //一次网络请求默认数量

    private DBListAdapter mWrapAdapter;
    private boolean isNoMore = false;
    private boolean isCritical = false;
    private boolean mIsVpDragger;
    private int mTouchSlop;
    private float startY;
    private float startX;
    private boolean isRegisterDataObserver;

    private DBContext mDBContext;

    /**
     * 当前RecyclerView类型
     */
    protected LayoutManagerType layoutManagerType;

    /**
     * 最后一个的位置
     */
    private int[] lastPositions;

    /**
     * 最后一个可见的item的位置
     */
    private int lastVisibleItemPosition;

    /**
     * 当前滑动的状态
     */
    private int currentScrollState = 0;

    /**
     * 触发在上下滑动监听器的容差距离
     */
    private static final int HIDE_THRESHOLD = 20;

    /**
     * 滑动的距离
     */
    private int mDistance = 0;

    /**
     * 是否需要监听控制
     */
    private boolean mIsScrollDown = true;

    /**
     * Y轴移动的实际距离（最顶部为0）
     */
    private int mScrolledYDistance = 0;

    /**
     * X轴移动的实际距离（最左侧为0）
     */
    private int mScrolledXDistance = 0;
    //scroll variables end

    public DBListView(DBContext dbContext) {
        this(dbContext, null);
        mDBContext = dbContext;
    }

    public DBListView(DBContext dbContext, AttributeSet attrs) {
        super(dbContext.getContext(), attrs);
        mDBContext = dbContext;
        init();
    }

    private void init() {
        mTouchSlop = ViewConfiguration.get(getContext().getApplicationContext()).getScaledTouchSlop();
        if (mPullRefreshEnabled) {
            setRefreshHeader(new DBRefreshIndicator(getContext().getApplicationContext()));
        }

        if (mLoadMoreEnabled) {
            setLoadMoreFooter(new DBLoadingFooter(mDBContext), false);
        }
    }

    @Override
    public void setAdapter(Adapter adapter) {
        if (mWrapAdapter != null && isRegisterDataObserver) {
            mWrapAdapter.getInnerAdapter().unregisterAdapterDataObserver(mDataObserver);
        }

        mWrapAdapter = (DBListAdapter) adapter;
        super.setAdapter(mWrapAdapter);

        mWrapAdapter.getInnerAdapter().registerAdapterDataObserver(mDataObserver);
        mDataObserver.onChanged();
        isRegisterDataObserver = true;

        mWrapAdapter.setRefreshHeader(mRefreshHeader);

        if (mLoadMoreEnabled && mWrapAdapter.getFooterViewsCount() == 0) {
            mWrapAdapter.addFooterView(mLoaderView);
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();

        if (mWrapAdapter != null && isRegisterDataObserver) {
            mWrapAdapter.getInnerAdapter().unregisterAdapterDataObserver(mDataObserver);
            isRegisterDataObserver = false;
        }
    }

    private class DataObserver extends AdapterDataObserver {
        @Override
        public void onChanged() {
            Adapter<?> adapter = getAdapter();
            if (adapter instanceof DBListAdapter) {
                DBListAdapter lRecyclerViewAdapter = (DBListAdapter) adapter;
                if (lRecyclerViewAdapter.getInnerAdapter() != null && mEmptyView != null) {
                    int count = lRecyclerViewAdapter.getInnerAdapter().getItemCount();
                    if (count == 0) {
                        mEmptyView.setVisibility(View.VISIBLE);
                        DBListView.this.setVisibility(View.GONE);
                    } else {
                        mEmptyView.setVisibility(View.GONE);
                        DBListView.this.setVisibility(View.VISIBLE);
                    }
                }
            } else {
                if (adapter != null && mEmptyView != null) {
                    if (adapter.getItemCount() == 0) {
                        mEmptyView.setVisibility(View.VISIBLE);
                        DBListView.this.setVisibility(View.GONE);
                    } else {
                        mEmptyView.setVisibility(View.GONE);
                        DBListView.this.setVisibility(View.VISIBLE);
                    }
                }
            }

            if (mWrapAdapter != null) {
                mWrapAdapter.notifyDataSetChanged();
                if (null != mLoaderView && mWrapAdapter.getInnerAdapter().getItemCount() < mPageSize) {
                    mLoaderView.setVisibility(GONE);
                }
            }
        }

        @Override
        public void onItemRangeChanged(int positionStart, int itemCount) {
            mWrapAdapter.notifyItemRangeChanged(positionStart + mWrapAdapter.getHeaderViewsCount() + 1, itemCount);
        }

        @Override
        public void onItemRangeInserted(int positionStart, int itemCount) {
            mWrapAdapter.notifyItemRangeInserted(positionStart + mWrapAdapter.getHeaderViewsCount() + 1, itemCount);
        }

        @Override
        public void onItemRangeRemoved(int positionStart, int itemCount) {
            mWrapAdapter.notifyItemRangeRemoved(positionStart + mWrapAdapter.getHeaderViewsCount() + 1, itemCount);
            if (mWrapAdapter.getInnerAdapter().getItemCount() < mPageSize) {
                mLoaderView.setVisibility(GONE);
            }
        }

        @Override
        public void onItemRangeMoved(int fromPosition, int toPosition, int itemCount) {
            int headerViewsCountCount = mWrapAdapter.getHeaderViewsCount();
            mWrapAdapter.notifyItemRangeChanged(fromPosition + headerViewsCountCount + 1, toPosition + headerViewsCountCount + 1 + itemCount);
        }
    }

    /**
     * 解决ViewPage横向滑动时，嵌套RecyclerView滑动冲突问题
     */
    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        int action = ev.getAction();
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                // 记录手指按下的位置
                startY = ev.getY();
                startX = ev.getX();
                // 初始化标记
                mIsVpDragger = false;
                break;
            case MotionEvent.ACTION_MOVE:
                // 如果viewpager正在拖拽中，那么不拦截它的事件，直接return false；
                if (mIsVpDragger) {
                    return false;
                }

                // 获取当前手指位置
                float endY = ev.getY();
                float endX = ev.getX();
                float distanceX = Math.abs(endX - startX);
                float distanceY = Math.abs(endY - startY);
                // 如果X轴位移大于Y轴位移，那么将事件交给viewPager处理。
                if (distanceX > mTouchSlop && distanceX > distanceY) {
                    mIsVpDragger = true;
                    return false;
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                // 初始化标记
                mIsVpDragger = false;
                break;
        }
        // 如果是Y轴位移大于X轴，事件交给swipeRefreshLayout处理。
        return super.onInterceptTouchEvent(ev);
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        if (mLastY == -1) {
            mLastY = ev.getY();
            mActivePointerId = ev.getPointerId(0);
            sumOffSet = 0;
        }
        switch (ev.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                mLastY = ev.getY();
                mActivePointerId = ev.getPointerId(0);
                sumOffSet = 0;
                break;
            case MotionEvent.ACTION_POINTER_DOWN:
                final int index = ev.getActionIndex();
                mActivePointerId = ev.getPointerId(index);
                mLastY = (int) ev.getY(index);
                break;
            case MotionEvent.ACTION_MOVE:
                int pointerIndex = ev.findPointerIndex(mActivePointerId);
                if (pointerIndex == -1) {
                    pointerIndex = 0;
                    mActivePointerId = ev.getPointerId(pointerIndex);
                }
                final int moveY = (int) ev.getY(pointerIndex);
                final float deltaY = (moveY - mLastY) / DRAG_RATE;
                mLastY = moveY;
                sumOffSet += deltaY;
                if (isOnTop() && mPullRefreshEnabled && !mRefreshing) {
                    mRefreshHeader.onMove(deltaY, sumOffSet);
                }
                break;
            case MotionEvent.ACTION_UP:
                mLastY = -1; // reset
                mActivePointerId = -1;
                if (isOnTop() && mPullRefreshEnabled && !mRefreshing/*&& appbarState == AppBarStateChangeListener.State.EXPANDED*/) {
                    if (mRefreshHeader != null && mRefreshHeader.onRelease()) {
                        if (mRefreshListener != null) {
                            mRefreshing = true;
                            mLoaderView.setVisibility(GONE);
                            mRefreshListener.onRefresh();
                        }
                    }
                }
                break;
        }
        return super.onTouchEvent(ev);
    }

    @Override
    protected boolean overScrollBy(int deltaX, int deltaY, int scrollX, int scrollY, int scrollRangeX, int scrollRangeY, int maxOverScrollX,
                                   int maxOverScrollY, boolean isTouchEvent) {
        if (deltaY != 0 && isTouchEvent) {
            mRefreshHeader.onMove(deltaY, sumOffSet);
        }
        return super.overScrollBy(deltaX, deltaY, scrollX, scrollY, scrollRangeX, scrollRangeY, maxOverScrollX, maxOverScrollY, isTouchEvent);
    }

    private int findMax(int[] lastPositions) {
        int max = lastPositions[0];
        for (int value : lastPositions) {
            if (value > max) {
                max = value;
            }
        }
        return max;
    }

    public boolean isOnTop() {
        return mPullRefreshEnabled && (mRefreshHeader.getHeaderView().getParent() != null);
    }

    /**
     * set view when no content item
     *
     * @param emptyView visiable view when items is empty
     */
    public void setEmptyView(View emptyView) {
        this.mEmptyView = emptyView;
        mDataObserver.onChanged();
    }

    /**
     * @param pageSize 一页加载的数量
     */
    public void refreshComplete(int pageSize) {
        this.mPageSize = pageSize;
        if (mRefreshing) {
            isNoMore = false;
            mRefreshing = false;
            mRefreshHeader.refreshFinish();

            if (mWrapAdapter.getInnerAdapter().getItemCount() < pageSize) {
                mLoaderView.setVisibility(GONE);
                mWrapAdapter.removeFooterView();
            } else if (mWrapAdapter.getFooterViewsCount() == 0) {
                mWrapAdapter.addFooterView(mLoaderView);
            }
        } else if (mLoadingData) {
            mLoadingData = false;
            mLoadMoreFooter.onComplete();
        }
        //visibleItemCount 10 lastVisibleItemPosition 9 totalItemCount 11 isNoMore false mRefreshing false
        //处理特殊情况 最后一行显示出来了加载更多的view的一部分
        if (mWrapAdapter.getInnerAdapter().getItemCount() == mPageSize) {
            isCritical = true;
        } else {
            isCritical = false;
        }
    }

    /**
     * @param pageSize 一页加载的数量
     * @param total    总数
     */
    public void refreshComplete(int pageSize, int total) {
        this.mPageSize = pageSize;
        if (mRefreshing) {
            mRefreshing = false;
            mRefreshHeader.refreshFinish();

            if (mWrapAdapter.getInnerAdapter().getItemCount() < pageSize) {
                mLoaderView.setVisibility(GONE);
                mWrapAdapter.removeFooterView();
            } else {
                if (mWrapAdapter.getFooterViewsCount() == 0) {
                    mWrapAdapter.addFooterView(mLoaderView);
                }
            }
        } else if (mLoadingData) {
            mLoadingData = false;
            mLoadMoreFooter.onComplete();
        }
        if (pageSize < total) {
            isNoMore = false;
        }
        //处理特殊情况 最后一行显示出来了加载更多的view的一部分
        if (mWrapAdapter.getInnerAdapter().getItemCount() == mPageSize) {
            isCritical = true;
        } else {
            isCritical = false;
        }
    }

    /**
     * 此方法主要是为了满足数据不满一屏幕或者数据小于pageSize的情况下，是否显示footview
     * 在分页情况下使用refreshComplete(int pageSize, int total, boolean false)就相当于refreshComplete(int pageSize, int total)
     *
     * @param pageSize       一页加载的数量
     * @param total          总数
     * @param isShowFootView 是否需要显示footview（前提条件是：getItemCount() < pageSize）
     */
    public void refreshComplete(int pageSize, int total, boolean isShowFootView) {
        this.mPageSize = pageSize;
        if (mRefreshing) {
            mRefreshing = false;
            mRefreshHeader.refreshFinish();
            if (isShowFootView) {
                mLoaderView.setVisibility(VISIBLE);
            } else {
                if (mWrapAdapter.getInnerAdapter().getItemCount() < pageSize) {
                    mLoaderView.setVisibility(GONE);
                    mWrapAdapter.removeFooterView();
                } else {
                    if (mWrapAdapter.getFooterViewsCount() == 0) {
                        mWrapAdapter.addFooterView(mLoaderView);
                    }
                }
            }
        } else if (mLoadingData) {
            mLoadingData = false;
            mLoadMoreFooter.onComplete();
        }
        if (pageSize < total) {
            isNoMore = false;
        }
        //处理特殊情况 最后一行显示出来了加载更多的view的一部分
        if (mWrapAdapter.getInnerAdapter().getItemCount() == mPageSize) {
            isCritical = true;
        } else {
            isCritical = false;
        }
    }

    /**
     * 设置是否已加载全部
     */
    public void setNoMore(boolean noMore) {
        mLoadingData = false;
        isNoMore = noMore;
        if (isNoMore) {
            mLoadMoreFooter.onNoMore();
            mLoaderView.setVisibility(VISIBLE);
        } else {
            mLoadMoreFooter.onComplete();
        }
    }

    /**
     * 设置自定义的RefreshHeader
     * 注意：setRefreshHeader方法必须在setAdapter方法之前调用才能生效
     */
    public void setRefreshHeader(IRefreshIndicator refreshHeader) {
        if (isRegisterDataObserver) {
            throw new RuntimeException("setRefreshHeader must been invoked before setting the adapter.");
        }
        this.mRefreshHeader = refreshHeader;
    }

    /**
     * 设置自定义的footerview
     *
     * @param loadMoreFooter 外部实现
     * @param isCustom       是否自定义footview
     */
    public void setLoadMoreFooter(ILoadMoreFooter loadMoreFooter, boolean isCustom) {
        this.mLoadMoreFooter = loadMoreFooter;
        if (isCustom) {
            if (null != mWrapAdapter && mWrapAdapter.getFooterViewsCount() > 0) {
                mWrapAdapter.removeFooterView();
            }
        }
        mLoaderView = loadMoreFooter.getFootView();
        mLoaderView.setVisibility(VISIBLE);

        //mLoaderView inflate的时候没有以RecyclerView为parent，所以要设置LayoutParams
        ViewGroup.LayoutParams layoutParams = mLoaderView.getLayoutParams();
        if (layoutParams != null) {
            mLoaderView.setLayoutParams(new LayoutParams(layoutParams));
        } else {
            mLoaderView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
        }

        if (isCustom) {
            if (mLoadMoreEnabled && mWrapAdapter.getFooterViewsCount() == 0) {
                mWrapAdapter.addFooterView(mLoaderView);
            }
        }

    }

    public void setPullRefreshEnabled(boolean enabled) {
        mPullRefreshEnabled = enabled;
    }

    /**
     * 底部加载是否可用
     */
    public void setLoadMoreEnabled(boolean enabled) {
//        if (mWrapAdapter == null) {
//            throw new NullPointerException("DBListAdapter cannot be null");
//        }
        mLoadMoreEnabled = enabled;
        if (!enabled) {
//            mWrapAdapter.removeFooterView(); // 此处有bug，enable为false时
        }
    }

    public void setRefreshProgressStyle(int style) {
        // TODO
    }

    public void setArrowImageView(int resId) {
        // TODO
    }

    public void setLoadingMoreProgressStyle(int style) {
        // TODO
    }

    public void setOnRefreshListener(IRefreshListener listener) {
        mRefreshListener = listener;
    }

    public void setOnLoadMoreListener(OnLoadMoreListener listener) {
        mLoadMoreListener = listener;
    }

    public void setOnNetWorkErrorListener(final OnNetWorkErrorListener listener) {
        mLoadMoreFooter.setNetworkErrorViewClickListener(listener);
    }

    /**
     * 设置颜色
     *
     * @param indicatorColor  Only call the method setRefreshProgressStyle(int style) to take effect
     * @param hintColor
     * @param backgroundColor
     */
    public void setHeaderViewColor(int indicatorColor, int hintColor, int backgroundColor) {
        if (mRefreshHeader instanceof DBRefreshIndicator) {
//            ArrowRefreshHeader arrowRefreshHeader = ((ArrowRefreshHeader) mRefreshHeader);
//            arrowRefreshHeader.setIndicatorColor(ContextCompat.getColor(getContext(), indicatorColor));
//            arrowRefreshHeader.setHintTextColor(hintColor);
//            arrowRefreshHeader.setViewBackgroundColor(backgroundColor);
        }
    }

    public void setLScrollListener(LScrollListener listener) {
        mLScrollListener = listener;
    }

    public interface LScrollListener {
        void onScrollUp();//scroll down to up

        void onScrollDown();//scroll from up to down

        void onScrolled(int distanceX, int distanceY);// moving state,you can get the move distance

        void onScrollStateChanged(int state);
    }

    public void refresh() {
        if (mRefreshHeader.getVisibleHeight() > 0 || mRefreshing) {// if RefreshHeader is Refreshing, return
            return;
        }
        if (mPullRefreshEnabled && mRefreshListener != null) {
            mRefreshHeader.onRefreshing();
            int offSet = mRefreshHeader.getHeaderView().getMeasuredHeight();
            mRefreshHeader.onMove(offSet, offSet);
            mRefreshing = true;

            mLoaderView.setVisibility(GONE);
            mRefreshListener.onRefresh();
        }
    }

    public void forceToRefresh() {
        if (mLoadingData) {
            return;
        }
        refresh();
    }

    @Override
    public void onScrolled(int dx, int dy) {
        super.onScrolled(dx, dy);

        int firstVisibleItemPosition = 0;
        LayoutManager layoutManager = getLayoutManager();

        if (layoutManagerType == null) {
            if (layoutManager instanceof LinearLayoutManager) {
                layoutManagerType = LayoutManagerType.LinearLayout;
            } else {
                throw new RuntimeException("Unsupported LayoutManager used. only supper LinearLayoutManager");
            }
        }

        firstVisibleItemPosition = ((LinearLayoutManager) layoutManager).findFirstVisibleItemPosition();
        lastVisibleItemPosition = ((LinearLayoutManager) layoutManager).findLastVisibleItemPosition();

        // 根据类型来计算出第一个可见的item的位置，由此判断是否触发到底部的监听器
        // 计算并判断当前是向上滑动还是向下滑动
        calculateScrollUpOrDown(firstVisibleItemPosition, dy);
        // 移动距离超过一定的范围，监听就没有啥实际的意义了
        mScrolledXDistance += dx;
        mScrolledYDistance += dy;
        mScrolledXDistance = Math.max(mScrolledXDistance, 0);
        mScrolledYDistance = Math.max(mScrolledYDistance, 0);
        if (mIsScrollDown && (dy == 0)) {
            mScrolledYDistance = 0;
        }
        //Be careful in here
        if (null != mLScrollListener) {
            mLScrollListener.onScrolled(mScrolledXDistance, mScrolledYDistance);
        }

        if (mLoadMoreListener != null && mLoadMoreEnabled) {
            int visibleItemCount = layoutManager.getChildCount();
            int totalItemCount = layoutManager.getItemCount();
            if (visibleItemCount > 0
                    && lastVisibleItemPosition >= totalItemCount - 1
                    && (isCritical ? totalItemCount >= visibleItemCount : totalItemCount > visibleItemCount)
                    && !isNoMore
                    && !mRefreshing) {

                mLoaderView.setVisibility(View.VISIBLE);
                if (!mLoadingData) {
                    mLoadingData = true;
                    mLoadMoreFooter.onLoading();
                    mLoadMoreListener.onLoadMore();
                }
            }
        }
    }

    @Override
    public void onScrollStateChanged(int state) {
        super.onScrollStateChanged(state);
        currentScrollState = state;

        if (mLScrollListener != null) {
            mLScrollListener.onScrollStateChanged(state);
        }
    }

    /**
     * 计算当前是向上滑动还是向下滑动
     */
    private void calculateScrollUpOrDown(int firstVisibleItemPosition, int dy) {
        if (null != mLScrollListener) {
            if (firstVisibleItemPosition == 0) {
                if (!mIsScrollDown) {
                    mIsScrollDown = true;
                    mLScrollListener.onScrollDown();
                }
            } else {
                if (mDistance > HIDE_THRESHOLD && mIsScrollDown) {
                    mIsScrollDown = false;
                    mLScrollListener.onScrollUp();
                    mDistance = 0;
                } else if (mDistance < -HIDE_THRESHOLD && !mIsScrollDown) {
                    mIsScrollDown = true;
                    mLScrollListener.onScrollDown();
                    mDistance = 0;
                }
            }
        }

        if ((mIsScrollDown && dy > 0) || (!mIsScrollDown && dy < 0)) {
            mDistance += dy;
        }
    }

    public enum LayoutManagerType {
        LinearLayout
    }
}
