package com.didi.carmate.dreambox.core.base;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * author: chenjing
 * date: 2020/5/6
 * <p>
 * 节点注册入口，SDK自身的节点以及第三方扩展的节点都必须注册到这里，解析模块树时将根据节点的[tag]将从这里获取并生成节点实例
 */
public class DBNodeRegistry {
    private static final Map<String, INodeCreator> sNodeMap = new ConcurrentHashMap<>();

    public static void registerNode(String nodeTag, INodeCreator nodeCreator) {
        sNodeMap.put(nodeTag, nodeCreator);
    }

    static Map<String, INodeCreator> getNodeMap() {
        return sNodeMap;
    }
}
