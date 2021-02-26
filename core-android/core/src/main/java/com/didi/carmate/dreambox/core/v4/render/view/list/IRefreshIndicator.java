package com.didi.carmate.dreambox.core.v4.render.view.list;

import android.view.View;

/**
 * author: chenjing
 * date: 2020/7/1
 */
public interface IRefreshIndicator {
    int STATE_DEFAULT = 0;      // 默认状态
    int STATE_READY = 1;        // 准备刷新，下拉距离可执行刷新操作的临界态。默认下拉距离大于 RefreshArea 高度时触发此状态
    int STATE_REFRESHING = 2;   // 刷新中
    int STATE_FINISH = 3;       // 刷新完成，默认延迟200ms后恢复成 STATE_DEFAULT

    /**
     * 处于可以刷新的状态，已经过了指定距离
     */
    void onPrepare();

    /**
     * 正在刷新
     */
    void onRefreshing();

    /**
     * 下拉移动
     */
    void onMove(float offSet, float sumOffSet);

    /**
     * 下拉松开
     */
    boolean onRelease();

    /**
     * 恢复默认
     */
    void onReset();

    /**
     * 下拉刷新完成
     */
    void refreshFinish();

    /**
     * 获取 header 区域里的View视图对象
     */
    View getHeaderView();

    /**
     * 获取Header的显示高度
     * header区域默认高度为0，下拉时高度动态计算
     */
    int getVisibleHeight();
}
