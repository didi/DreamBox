## 事件管道

Added in v0.2

### DSL设计

主动发送事件到Native中

```xml
<sendEvent eid="事件ID">
    <!-- msg作为子节点可以更好地承接字典数据 -->
    <msg orderId="12345" routeId="45454" />
    <callback  msgTo="meta占位">
        <!-- 动作节点 -->
    </callback>
</sendEvent>
```

被动监听Native所发出的事件

```xml
<onEvent eid="事件ID" msgTo="meta占位">
    <!-- 动作节点 -->
</onEvent>
```

详细用法参考 [Android](./event_android.md) 和 [iOS](./event_ios.md) 的详细说明文档