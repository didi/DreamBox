package com.didi.carmate.dreambox.shell;

import org.junit.Test;

import static org.junit.Assert.*;

public class DreamBoxTest {
    @Test
    public void testSort() {
        DreamBox dreamBox = DreamBox.getInstance();
        System.out.println(dreamBox.preProcessors);
        assertEquals(DreamBox.FLAG_MD5, dreamBox.preProcessors.get(0).flag());
    }
}