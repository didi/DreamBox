## `<text>`

Added in v0.1

### 设计

用于展示一段文字

### 属性

#### Added in v0.1
- `src` 必需。文字内容，可以在meta中获取，如`${response.title}`意为取response json数据中的title下的字符串数据
- `size` 字体大小，单位为`px`或`dp`，默认`13dp`
- `color` 文字颜色，默认纯黑色
- `style` 文字样式，默认`normal`
  - `normal` 常规
  - `bold` 加粗

#### Added in v0.2
- `gravity` 内部文字内容布局方式，可取值`left` `right` `center`
  - `left` 左对齐
  - `right` 右对齐
  - `center` 整体居中

#### Added in v0.3
- `ellipsize` 文本显示不完整时，显示省略号以及省略号显示的位置
  - `start` 显示省略号，且在开头显示
  - `middle` 显示省略号，且在中间显示
  - `end` 显示省略号，且在结尾显示
- `maxLines` 设置文本显示的行数
- `minWidth` 设置文本显示的最小宽度
- `maxWidth` 设置文本显示的最大宽度
- `minHeight` 设置文本显示的最小高度
- `maxHeight` 设置文本显示的最大高度

### 交互响应

无特殊