## `<invoke>`

Added in v0.1

### 设计

用于搭配`<action-alias>`使用，表示调用某个动作领域

### 属性

- `alias` 必需。指定对应`<action-alias>`的ID
- `src` 可以指定输入数据，和`<action-alias>`的`src`属性一样，是dict格式，若有同样数据，那么此数据拥有更高优先级，会产生覆盖

### 子节点

无