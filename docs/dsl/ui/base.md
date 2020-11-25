## 视图节点（UI Element）

所有视图节点在`<dbl>`下被`<render>`包裹，以便于编辑和理解。

Added in v0.1

### 设计

DreamBox的渲染设计思想参照Android约束布局，内部子节点采用上下左右的相对关系达成最终的布局。

### 属性

##### 尺寸单位

- `px`像素
- `dp`根据屏幕密度计算的单位，方便适配。计算规则：720P下的像素值除以2为对应的dp值，1080P下则除以3

##### 常规属性

- `id` 表示此视图节点的唯一ID，属性值为字符串类型。`<dbl>`根节点的ID在DSL中以`parent`表示，Runtime中以0表示
- `marginTop` 外部上边距
- `marginBottom` 外部下边距
- `marginLeft` 外部左边距
- `marginRight` 外部右边距
- `backgroundColor` ARGB格式的背景色色值，以`#`开头，至少6位RGB码（无透明度）
- `width` 可选自：
  - `wrap`（默认）自适应 内置组件自适应规规则
    - view：不支持wrap，wrapHeight = 0，wrapWidth = 0
    - image：不支持wrap，wrapHeight = 0，wrapWidth = 0
    - text：wrapHeight = 文字高，wrapWidth = 文字宽
    - flow：wrapHeight = 内容高，wrapWidth = 内容宽
    - list：不支持wrap，wrapHeight = 0，wrapWidth = 0
    - progress：不支持wrap，wrapHeight = 0，wrapWidth = 0
    - loading：wrapHeight = 30，wrapWidth = 30
    - button：wrapHeight = 按钮文字高，wrapWidth = 按钮文字宽
  - `fill`铺版
  - 具体数值，如`100px`
  - `0` 跟随布局约束属性计算大小
    - 若视图A左右均跟随视图B，则视图A的宽度会强制等于视图B的宽度
- `height` 同`width`
- `visibleOn` 属性值接受元数据中的bool值，若给定key的数据变为true则展示（所有视图默认为可见）

##### Added in v0.3
- `userInteractionEnabled`是否允许用户交互，默认为false

##### 布局约束属性

- `leftToLeft` 值为其他视图节点的ID，说明当前视图的左边以指定ID的左边为准
- `leftToRight` 值为其他视图节点的ID，说明当前视图的左边以指定ID的右边为准
- `rightToRight` 值为其他视图节点的ID，说明当前视图的右边以指定ID的右边为准
- `rightToLeft` 值为其他视图节点的ID，说明当前视图的右边以指定ID的左边为准
- `topToTop` 值为其他视图节点的ID，说明当前视图的上边以指定ID的上边为准
- `topToBottom` 值为其他视图节点的ID，说明当前视图的上边以指定ID的下边为准
- `bottomToTop` 值为其他视图节点的ID，说明当前视图的下边以指定ID的上边为准
- `bottomToBottom` 值为其他视图节点的ID，说明当前视图的下边以指定ID的下边为准

> 举例：在视图宽高为wrap的情况下，若视图A的左边、右边分别视图B的左边、右边为准，也可以理解为视图A与B的垂直中心线对齐。上下对齐即横向中心线对齐

#### 特殊说明

后边所介绍的子节点中，有这样一条规则：如果这个视图节点拥有`src`属性，则同时具备`srcMock`属性。此属性含义与`src`属性一致，功能用于mock测试，所以在数据的优先级上高于`src`。CLI将保证`srcMock`属性在发布前的编译过程中被移除掉，不影响线上效果。

### 子节点

除`<list>`外，所有的视图节点的子节点只能是回调事件节点，不可以有视图节点的嵌套。

- `onClick` 当用户点击
- `onVisible` 当用户可见
- `onInvisible` 当用户不可见

