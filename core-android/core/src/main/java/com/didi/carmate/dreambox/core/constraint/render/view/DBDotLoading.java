package com.didi.carmate.dreambox.core.constraint.render.view;

import android.animation.ArgbEvaluator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.ColorInt;

import com.didi.carmate.dreambox.core.utils.DBScreenUtils;

/**
 * author: chenjing
 * date: 2020/5/23
 */
public class DBDotLoading extends View {
    private final ArgbEvaluator evaluator = new ArgbEvaluator(); //共用方法，防止重复新建

    @ColorInt
    private int bgColor;

    private int viewWidth;
    private int viewHeight;
    private int minRadius;
    private int maxRadius;
    private int minDotColor;
    private int maxDotColor;

    private Paint paint;

    private int step = 0;

    private Handler handler = new Handler();

    private int circleCenterY;
    private int circleCenterAX;
    private int circleCenterBX;
    private int circleCenterCX;

    public DBDotLoading(Context context) {
        super(context);
        init();
    }

    public DBDotLoading(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public DBDotLoading(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        this.setMeasuredDimension(viewWidth, viewHeight);
    }

    private void init() {
        viewWidth = DBScreenUtils.dip2px(getContext(), 84 / 2);
        viewHeight = DBScreenUtils.dip2px(getContext(), 20 / 2);

        minRadius = DBScreenUtils.dip2px(getContext(), 7 / 2);
        maxRadius = DBScreenUtils.dip2px(getContext(), 10 / 2);
        minDotColor = Color.parseColor("#A6AAAB");
        maxDotColor = Color.parseColor("#2B3338");

        paint = new Paint();
        paint.setAntiAlias(true);
        paint.setStyle(Paint.Style.FILL);

        circleCenterAX = viewWidth / 6;
        circleCenterBX = viewWidth / 2;
        circleCenterCX = viewWidth / 6 * 5;
        circleCenterY = viewHeight / 2;
    }

    @Override
    protected void onDraw(Canvas canvas) {
//        if (bgColor != Color.TRANSPARENT) {
//            canvas.drawColor(bgColor);
//        }

        // 计算每个圆点的变化百分比
        float firstPercent = 1 - Math.abs(step - 8) / 8.0f;
        float secondPercent = 1 - Math.abs(step - 16) / 8.0f;
        float thirdPercent = 1 - Math.abs(step - 24) / 8.0f;

        // 处理超过请过，保证在 0-1 之间
        firstPercent = Math.min(1f, Math.max(0f, firstPercent));
        secondPercent = Math.min(1f, Math.max(0f, secondPercent));
        thirdPercent = Math.min(1f, Math.max(0f, thirdPercent));

        // 根据不同百分比渲染大小与颜色

        int firstRadius = minRadius + (int) ((maxRadius - minRadius) * firstPercent);
        int firstColor = (int) evaluator.evaluate(firstPercent, minDotColor, maxDotColor);
        paint.setColor(firstColor);
        canvas.drawCircle(circleCenterAX, circleCenterY, firstRadius, paint);

        int secondRadius = minRadius + (int) ((maxRadius - minRadius) * secondPercent);
        int secondColor = (int) evaluator.evaluate(secondPercent, minDotColor, maxDotColor);
        paint.setColor(secondColor);
        canvas.drawCircle(circleCenterBX, circleCenterY, secondRadius, paint);


        int thirdRadius = minRadius + (int) ((maxRadius - minRadius) * thirdPercent);
        int thirdColor = (int) evaluator.evaluate(thirdPercent, minDotColor, maxDotColor);
        paint.setColor(thirdColor);
        canvas.drawCircle(circleCenterCX, circleCenterY, thirdRadius, paint);
    }

    public void updateStepView(int step) {
        this.step = step;
        this.invalidate();
    }

    Runnable loadingRunn = new Runnable() {
        @Override
        public void run() {
            updateStepView(step);
            step %= 32;
            step++;
            handler.postDelayed(loadingRunn, 33);
        }
    };

    public void startLoading() {
        step = 0;
        handler.removeCallbacks(loadingRunn);
        handler.post(loadingRunn);
    }

    public void stopLoading() {
        step = 0;
        handler.removeCallbacks(loadingRunn);
    }

    public void setBgColor(@ColorInt int color) {
        bgColor = color;
        invalidate();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (handler != null) {
            handler.removeCallbacks(loadingRunn);
        }
    }
}