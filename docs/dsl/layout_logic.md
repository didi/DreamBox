# DreamBox的布局逻辑

## 0. 布局方式

为了进一步降低学习成本以及IOS和Android两端布局的一致性，DreamBox的布局逻辑从v0.4版本，用flexbox方式替换了原来的约束布局方式。

## 1. 布局引擎

flexbox方式实现上，为保证稳定性和一致性，底层采用了被广泛使用的yoga作为布局引擎的实现。

## 2. 布局属性

### 2.1 容器支持的布局相关的属性

- flex-direction
    -flex-direction
    -row
    -column
    -row-reverse
    -column-reverse
- flex-wrap
    - wrap
    - nowrap
    - wrap-reverse
- justify-content
    - flex-start
    - flex-end
    - center
    - space-between
    - space-around
    - space-evenly
- align-items
    - flex-start
    - flex-end
    - center
    - stretch
    - baseline
- align-content
    - flex-start
    - flex-end
    - center
    - stretch
    - space-between
    - space-around

### 2.2 子元素支持的布局相关的属性
- 宽
    - key: width
    - value: 固定值，例：20dp; 百分比，例：50%
- 高
    - key: height
    - value: 固定值，例：20dp; 百分比，例：100%
- 外边距
    - key: margin，value: 固定值，例：20dp
    - key: marginLeft，value: 固定值，例：10dp，优先级大于margin
    - key: marginTop，value: 固定值，例：10dp，优先级大于margin
    - key: marginRight，value: 固定值，例：10dp，优先级大于margin
    - key: marginBottom，value: 固定值，例：10dp，优先级大于margin
- 内边距
    - key: padding，value: 固定值，例：20dp
    - key: paddingLeft，value: 固定值，例：10dp，优先级大于padding
    - key: paddingTop，value: 固定值，例：10dp，优先级大于padding
    - key: paddingRight，value: 固定值，例：10dp，优先级大于padding
    - key: paddingBottom，value: 固定值，例：10dp，优先级大于padding
- 弹性扩展
    - key: flex-grow
    - value: float型，例：1，2.5
- 弹性扩收缩
    - key: flex-shrink
    - value: float型，例：1，2.5
- 弹性伸缩基准值
    - key: flex-basis
    - value: 固定值，例：20dp; 百分比，例：50%
- 单个元素在侧轴的对齐方式
    - key: align-self
    - value: flex-start,flex-end,center,stretch,baseline
- 单个元素位置布局方式
    - key: positionType
    - value: absolute 相对布局，relative 绝对布局
- 绝对布局方式，左对齐及左边距
    - key: positionLeft
    - value: 固定值，例：20dp; 百分比，例：50%
- 绝对布局方式，顶部对齐及顶部边距
    - key: positionTop
    - value: 固定值，例：20dp; 百分比，例：50%
- 绝对布局方式，右对齐及右边距
    - key: positionRight
    - value: 固定值，例：20dp; 百分比，例：50%
- 绝对布局方式，底部对齐及底部边距
    - key: positionBottom
    - value: 固定值，例：20dp; 百分比，例：50%
- 宽高比
    - key: aspectRatio
    - value: float型
