package com.didi.carmate.dreambox.wrapper.v4.inner;

import androidx.annotation.FloatRange;
import androidx.annotation.RestrictTo;

@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public class WrapperConfig {

    public boolean report = true;

    @FloatRange(from = 0, to = 1)
    public float sampleFrequency = 0.1f;

    public WrapperConfig() {
    }

    public WrapperConfig(boolean report, @FloatRange(from = 0, to = 1) float sampleFrequency) {
        this.report = report;
        this.sampleFrequency = sampleFrequency;
    }

}
