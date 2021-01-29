package com.didi.carmate.dreambox.core;

import com.didi.carmate.dreambox.core.v4.base.DBNode;
import com.didi.carmate.dreambox.wrapper.v4.Wrapper;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

import org.junit.Test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import static org.junit.Assert.*;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
public class ExampleUnitTest {
    private static final String ARR_TAG_START = "`";
    private static final String ARR_TAG_END = "``";

    @Test
    public void addition_isCorrect() {
        String content = readFileByLines("src/test/assets/test1.json");
//        String content = readFileByLines("src/test/assets/test2.json");

        JsonObject sourceData = new Gson().fromJson(content, JsonObject.class);
        String rawKey = "ext.data";
        rawKey = rawKey.replace("[", ARR_TAG_START);
        rawKey = rawKey.replace("]", ARR_TAG_END);
        String[] arrKeys = rawKey.split("\\.");
        JsonElement jsonElement = getJsonElement(arrKeys, sourceData);
        jsonElement.toString();
    }

    private JsonElement getJsonElement(String[] arrKeys, JsonObject sourceData) {
        JsonElement jsonElement = sourceData;
        int i = 0;
        while (i < arrKeys.length) {
            if (isJsonArrayKey(arrKeys[i])) {
                JsonArrayKey jsonArrayKey = getJsonArrayKey(arrKeys[i]);
                JsonElement tmpElement = jsonElement.getAsJsonObject().get(jsonArrayKey.key);
                if (tmpElement.isJsonArray()) {
                    jsonElement = tmpElement.getAsJsonArray().get(jsonArrayKey.pos);
                }
            } else {
                jsonElement = jsonElement.getAsJsonObject().get(arrKeys[i]);
            }
            i++;
        }
        return jsonElement;
    }

    private String readFileByLines(String fileName) {
        File file = new File(fileName);
        StringBuilder content = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String tmpLine = null;
            while ((tmpLine = reader.readLine()) != null) {
                content.append(tmpLine);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return content.toString();
    }

    private static class JsonArrayKey {
        int pos = -1;
        String key = "";
    }

    private JsonArrayKey getJsonArrayKey(String rawArrayKey) {
        JsonArrayKey arrayKey = new JsonArrayKey();
        int tagStart = rawArrayKey.indexOf(ARR_TAG_START);
        int tagEnd = rawArrayKey.indexOf(ARR_TAG_END);
        String strPos = rawArrayKey.substring(tagStart + 1, tagEnd);
        arrayKey.key = rawArrayKey.substring(0, tagStart);
        arrayKey.pos = Integer.parseInt(strPos);
        return arrayKey;
    }

    private boolean checkJsonArray(String rawKey, JsonElement element, int pos) {
        if (null == element) {
            System.out.println("keys: " + rawKey + " -> element is null");
            return false;
        } else if (!element.isJsonArray()) {
            System.out.println("keys: " + rawKey + " -> element is not JsonArray");
            return false;
        } else if (element.getAsJsonArray().size() <= pos) {
            System.out.println("keys: " + rawKey + " -> index large than array size");
            return false;
        }
        return true;
    }

    private boolean isJsonArrayKey(String rawArrayKey) {
        return rawArrayKey.contains(ARR_TAG_START) && rawArrayKey.contains(ARR_TAG_END);
    }
}