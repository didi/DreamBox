package com.didi.carmate.dreambox.shell;

import androidx.annotation.FloatRange;

public class DreamBoxConfig {

    public boolean report = true;

    @FloatRange(from = 0, to = 1)
    public float sampleFrequency = 0.1f;

}
