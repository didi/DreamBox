package com.didi.carmate.dreambox.core.base;

/**
 * author: chenjing
 * date: 2020/5/6
 * <p>
 * 创建节点实例的抽象接口，每个节点都需要实现此接口，并返回自身的一个实例
 */
public interface INodeCreator {
    IDBNode createNode(DBContext dbContext);
}
