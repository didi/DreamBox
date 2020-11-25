## `<view>`

Added in v0.1

### 设计
版本 | 描述
---|---
v0.1 | 占位符一样的存在，本身在不设置背景颜色时并不实际渲染可见内容，但却会占用布局尺寸，背景设置支持纯色
v0.2 | 支持形状设置(直角矩形/圆角矩形)，矩形边框设置(宽度/颜色)，矩形背景设置(纯背景色/过渡背景色[水平方向、垂直方向])

### 属性

#### Added in v0.1
- `backgroundColor` 设置背景颜色

#### Added in v0.2
- `radius` 矩形圆角半径
- `borderWidth` 设置矩形边框宽度
- `borderColor` 设置矩形边框颜色
- `gradientColor` 设置背景颜色为过渡色，此选项优先级高于 `backgroundColor` ，颜色数需大于等于2个且用 `-` 连接，例："#711234-#269869-#269869",
- `gradientOrientation` 颜色过渡方向，可选，默认为垂直。取值[horizontal]表示水平，[vertical]表示垂直

#### DSLv3.0
- `radiusLT` 矩形左上圆角半径
- `radiusRT` 矩形右上圆角半径
- `radiusRB` 矩形右下圆角半径
- `radiusLB` 矩形左下圆角半径

### 交互响应

无特殊
