## `<pack>`

Added in v0.3

### 设计
版本 | 描述
---|---
v0.3 | 虚拟容器，用于包裹其他view对象，实现对多个对象的整体布局

### 属性

#### Added in v0.3
位置属性
- `leftToLeft` 值为其他视图节点的ID，说明当前视图的左边以指定ID的左边为准
- `leftToRight` 值为其他视图节点的ID，说明当前视图的左边以指定ID的右边为准
- `rightToRight` 值为其他视图节点的ID，说明当前视图的右边以指定ID的右边为准
- `rightToLeft` 值为其他视图节点的ID，说明当前视图的右边以指定ID的左边为准
- `topToTop` 值为其他视图节点的ID，说明当前视图的上边以指定ID的上边为准
- `topToBottom` 值为其他视图节点的ID，说明当前视图的上边以指定ID的下边为准
- `bottomToTop` 值为其他视图节点的ID，说明当前视图的下边以指定ID的上边为准
- `bottomToBottom` 值为其他视图节点的ID，说明当前视图的下边以指定ID的下边为准

边距属性
- `marginTop` 外部上边距
- `marginBottom` 外部下边距
- `marginLeft` 外部左边距
- `marginRight` 外部右边距


### 交互响应

无特殊
