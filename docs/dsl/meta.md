## 元数据节点 `<meta>`

Added in v0.1

### 设计

在DSL结构中用来放置元数据。可以理解为单个DreamBox实例领域内的全局变量池，key为变量名，value为值。

```xml
<meta
    confirm="false"
    response="null"
/>
```
解释：声明两个变量，confirm默认为false，response为空，后续可以用来承载网络回包数据

### 属性

无

### 子节点

无