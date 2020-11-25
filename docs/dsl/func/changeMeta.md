## `<changeMeta>`

Added in v0.1

### 设计

表示要改变meta中的某个数据值

### 属性

属性的key与meta中需要改变的值的key一致，value即新写入的值。

### 子节点

无

### 示例

```xml
<onClick>
    <changeMeta key="confirm" value="true">
</onClick>
```
意为其父节点被点击后将meta中key为`confirm`的值改为`true`