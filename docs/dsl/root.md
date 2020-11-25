## 根节点`<dbl>`

`<dbl>` DreamBox Language

### 设计

一个根节点对应一个DreamBox视图实例。

### 属性

#### Added in v0.1

- `changeOn` 指对哪些数据敏感，当相关数据发生变化时，当前DreamBox视图整体会刷新，属性内容为数据的key，可通过`|`连接多个数值
  ```xml
<dbl changeOn="order_id|refresh">
  ```
- `dismissOn` 当哪个数据（必须是bool型）变为true时，会消失（若展现形式为弹窗或页面则为消失，否则是不可见）

> 后续所有手册中声明的属性，若无明显标注，默认将是非必需的

#### Added in v0.2

- `scroll` 滚动能力，根节点默认不支持滚动，打开此属性可实现水平或垂直滚动能力。暂不支持滑动嵌套，打开此能力后子视图list节点将无法支持
  - `vertical` 垂直滚动
  - `horizontal` 水平滚动

### 子节点

- `<meta>`节点，包含元数据kv对
- `<onVisible>` 当对用户可见，可包含动作节点
- `<onInvisible>` 当对用户不可见，可包含动作节点
- `<onEvent>` 当接收到native发送过来的事件
- `<render>`节点
- `<action-alias>`节点