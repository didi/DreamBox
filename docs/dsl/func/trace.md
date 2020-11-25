## `<trace>`

Added in v0.1

### 设计

用于表示一次埋点事件

### 属性

- `key` 必需。代表埋点事件的key

### 子节点

- `<attr>` 代表此埋点的属性，包含KV对，可多个
  - `key` 必需。此属性的key
  - `value` 必需。此属性的值

### 示例

```xml
<trace
    dependOn="traceEnable"
    key="beat_order_pv">
    <attr key="uid" value="${uid}" />
    <attr key="oid" value="${oid}" />
</trace>
```