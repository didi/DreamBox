package com.didi.carmate.dreambox.core.v4.render.view;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.NinePatchDrawable;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.List;

/**
 * author: chenjing
 * date: 2020/6/29
 */
public class PatchDrawableFactory {
    private static final int NO_COLOR = 0x00000001;

    public static NinePatchDrawable createNinePatchDrawable(Resources res, Bitmap bitmap) {
        RangeLists rangeLists = getPatchRange(bitmap);
        Bitmap trimmedBitmap = trimBitmap(bitmap);
        ByteBuffer buffer = getByteBuffer(rangeLists.rangeListX, rangeLists.rangeListY);
        return new NinePatchDrawable(res, trimmedBitmap, buffer.array(), new Rect(), null);
    }

    public static DBPatchRepeatDrawable createRepeatPatchDrawable(Resources res, Bitmap bitmap) {
        RangeLists rangeLists = getPatchRange(bitmap);
        Bitmap trimmedBitmap = trimBitmap(bitmap);
        return new DBPatchRepeatDrawable(trimmedBitmap, rangeLists);
    }

    public static RangeLists getPatchRange(Bitmap bitmap) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();

        List<Range> rangeListX = new ArrayList<>();

        int pos = -1;
        for (int i = 1; i < width - 1; i++) {
            int color = bitmap.getPixel(i, 0);
            int alpha = Color.alpha(color);
            int red = Color.red(color);
            int green = Color.green(color);
            int blue = Color.blue(color);
            if (alpha == 255 && red == 0 && green == 0 && blue == 0) {
                if (pos == -1) {
                    pos = i - 1;
                }
            } else {
                if (pos != -1) {
                    Range range = new Range();
                    range.start = pos;
                    range.end = i - 1;
                    rangeListX.add(range);
                    pos = -1;
                }
            }
        }
        if (pos != -1) {
            Range range = new Range();
            range.start = pos;
            range.end = width - 2;
            rangeListX.add(range);
        }
//        for (Range range : rangeListX) {
//            System.out.println("(" + range.start + "," + range.end + ")");
//        }

        List<Range> rangeListY = new ArrayList<>();
        pos = -1;
        for (int i = 1; i < height - 1; i++) {
            int color = bitmap.getPixel(0, i);
            int alpha = Color.alpha(color);
            int red = Color.red(color);
            int green = Color.green(color);
            int blue = Color.blue(color);
            if (alpha == 255 && red == 0 && green == 0 && blue == 0) {
                if (pos == -1) {
                    pos = i - 1;
                }
            } else {
                if (pos != -1) {
                    Range range = new Range();
                    range.start = pos;
                    range.end = i - 1;
                    rangeListY.add(range);
                    pos = -1;
                }
            }

        }
        if (pos != -1) {
            Range range = new Range();
            range.start = pos;
            range.end = height - 2;
            rangeListY.add(range);
        }
//        for (Range range : rangeListY) {
//            System.out.println("(" + range.start + "," + range.end + ")");
//        }

        RangeLists rangeLists = new RangeLists();
        rangeLists.rangeListX = rangeListX;
        rangeLists.rangeListY = rangeListY;

        return rangeLists;
    }

    private static ByteBuffer getByteBuffer(List<Range> rangeListX, List<Range> rangeListY) {
        ByteBuffer buffer = ByteBuffer.allocate(4 + 4 * 7 + 4 * 2 * rangeListX.size() + 4 * 2 * rangeListY.size() + 4 * 9).order(ByteOrder.nativeOrder());
        buffer.put((byte) 0x01); // was serialised
        buffer.put((byte) (rangeListX.size() * 2)); // x div
        buffer.put((byte) (rangeListY.size() * 2)); // y div
        buffer.put((byte) 0x09); // color

        // skip
        buffer.putInt(0);
        buffer.putInt(0);

        // padding
        buffer.putInt(0);
        buffer.putInt(0);
        buffer.putInt(0);
        buffer.putInt(0);

        // skip 4 bytes
        buffer.putInt(0);

        for (Range range : rangeListX) {
            buffer.putInt(range.start);
            buffer.putInt(range.end);
        }
        for (Range range : rangeListY) {
            buffer.putInt(range.start);
            buffer.putInt(range.end);
        }
        buffer.putInt(NO_COLOR);
        buffer.putInt(NO_COLOR);
        buffer.putInt(NO_COLOR);
        buffer.putInt(NO_COLOR);
        buffer.putInt(NO_COLOR);
        buffer.putInt(NO_COLOR);
        buffer.putInt(NO_COLOR);
        buffer.putInt(NO_COLOR);
        buffer.putInt(NO_COLOR);

        return buffer;
    }

    public static Bitmap trimBitmap(Bitmap bitmap) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();

        return Bitmap.createBitmap(bitmap, 1, 1, width - 2, height - 2);
    }

    public static class RangeLists {
        public List<Range> rangeListX;
        public List<Range> rangeListY;
    }

    public static class Range {
        public int start;
        public int end;
    }
}