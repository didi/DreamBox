## `<actionAlias>`

Added in v0.1

### 设计

用以包含通用的其他动作节点，理解上可以认为是代码中的函数，将通用的语句收集在一起。

### 属性

- `id` 必需。此动作领域在当前DBL下的唯一ID
- `src` 必需。向子节点提供数据，格式为dict

### 子节点

任何其他动作节点。

### 示例

```xml
<actionAlias
    id="aa_1"
    src="${data-body}">
    <!-- 此时展示toast的内容为“张三” -->
    <toast src="${name}">
</actionAlias>
```
解释：`data-body`是json结构，作为入参传入此actionAlias，在此actionAlias的领域内的`${name}`实际上是`data-body`中的`name`字段：
```json
{
    "data-body":{
        "name":"simple name"
    }
}
```