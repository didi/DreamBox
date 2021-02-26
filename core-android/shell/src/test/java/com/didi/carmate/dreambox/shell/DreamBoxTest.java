package com.didi.carmate.dreambox.shell;

import com.didi.carmate.dreambox.shell.v4.DreamBox;

import org.junit.Test;

public class DreamBoxTest {
    @Test
    public void testSort() {
        DreamBox dreamBox = DreamBox.getInstance();
        System.out.println(dreamBox.preProcessors);
        assertEquals(DreamBox.FLAG_MD5, dreamBox.preProcessors.get(0).flag());
    }
}