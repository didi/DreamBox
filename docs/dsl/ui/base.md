## 视图节点（UI Element）

所有视图节点在`<dbl>`下被`<layout type="yoga">`包裹，以便于编辑和理解。

### 设计

DreamBox布局从v0.4开始由约束布局替换为flexbox布局，底层采用yoga实现。`layout`节点为容器节点，通过`layout`节点的`type`属性指定具体布局类型，目前只支持`yoga`，将来可通过扩展此属性实现更多布局类型。

### 尺寸单位

- `px`像素
- `dp`根据屏幕密度计算的单位，方便适配。计算规则：720P下的像素值除以2为对应的dp值，1080P下则除以3

### 常规属性

#### Added in v0.1

- `id` 表示此视图节点的唯一ID，属性值为字符串类型。`<dbl>`根节点的ID在DSL中以`parent`表示，Runtime中以0表示
- `marginLeft` 外部左边距
- `marginTop` 外部上边距
- `marginRight` 外部右边距
- `marginBottom` 外部下边距
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

#### Added in v0.3

- `userInteractionEnabled`是否允许用户交互，默认为false

#### Added in v0.4

- `width` 增加支持百分比
- `height` 增加支持百分比
- `background` 设置本地/远程背景图片
- `borderWidth` 设置边框宽度
- `borderColor` 设置边框颜色
- `radius` 设置四个角圆角
- `radiusLT` 单独设置左上角圆角，优先级高于`radius`
- `radiusRT` 单独设置右上角圆角，优先级高于`radius`
- `radiusRB` 单独设置右下角圆角，优先级高于`radius`
- `radiusLB` 单独设置左下角圆角，优先级高于`radius`
- `margin` 设置左上右下外边距，v0.4之前的marginLeft、marginTop、marginRight、marginBottom优先级高于margin
- `padding` 设置左上右下内边距
- `paddingLeft` 单独设置左内边距，优先级高于`padding`
- `paddingTop` 单独设置上内边距，优先级高于`padding`
- `paddingRight` 单独设置右内边距，优先级高于`padding`
- `paddingBottom` 单独设置下内边距，优先级高于`padding`

父容器是flexbox类型时(<layout type="yoga">)，UI节点如下属性生效，具体可参考[布局逻辑](https://didi.github.io/DreamBox/#/dsl/layout_logic)里相关内容

- `flexGrow` 设置弹性扩展比例
- `flexShrink` 设置弹性收缩比例
- `flexBasis` 设置弹性伸缩基准值
- `alignSelf` 设置元素在侧轴的对齐方式
  - `flex-start` 上/左对齐
  - `flex-end` 右/下对齐
  - `center` 居中
  - `stretch` 主轴方向拉伸
  - `baseline` 基线对齐
- `positionType` 位置排列方式
  - `relative` 默认
  - `absolute` 绝对布局方式，采用此方式时，positionLeft/positionTop/positionRight/positionBottom 生效
- `positionLeft` 设置左边对齐及左边距
- `positionTop` 设置顶部对齐及顶部边距
- `positionRight` 设置右边对齐及右边距
- `positionBottom` 设置底部对齐及底部边距
- `aspectRatio` 设置宽高比

### 特殊说明

无

### 子节点

除`<list>`外，所有的视图节点的子节点只能是回调事件节点，不可以有视图节点的嵌套。

- `onClick` 当用户点击
- `onVisible` 当用户可见
- `onInvisible` 当用户不可见

