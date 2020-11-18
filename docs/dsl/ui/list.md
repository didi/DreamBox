## `<list>`

### 兼容性
from DSLv2.0

### 设计

用于展示一个列表，是可包含视图子节点的视图节点。

### 属性

#### DSLv2.0
- `src` 必需。用于代表列表的数据源，内容必须是json（dict结构）中类型为数组的节点，以方便列表的cell元素使用，可被`srcMock`覆盖
- `oritation` 表示列表布局方向，vertical: 垂直布局、horizontal: 水平布局

#### DSLv3.0
- `pullRefresh` 是否支持下拉刷新，值为布尔值
- `loadMore` 是否支持底部加载更多，值为布尔值
- `pageIndex` 表示当前页面的索引值，配合`loadMore`使用，值为字符串，指向`meta`中的某个变量，此变量只能存储整型数据，在加载更多执行后此值会被SDK执行+1操作

### 交互响应

无特殊

### 子节点

#### DSLv2.0
可包含3种类型的子节点
1. `<header>`（可选）用于形容列表头部区域
2. `<footer>`（可选）用于形容列表尾部区域
3. `<vh>`（必需）用于形容列表cell视图

- `<header>`
	- `<header>` 可以理解为一个视图容器，内部可包括其他的视图节点作为子节点。额外需要声明的有：
	  - 对于`<header>`的子节点来说，`<header>`即被认为是`parent`
	  - 其子节点在获取数据时，同其它普通节点，可从`meta`或全局数据池里获取，详细参考[工作原理][数据]一章
- `<vh>`
	- `<vh>` 可以理解为一个视图容器，内部可包括其他的视图节点作为子节点。额外需要声明的有：
	  - 对于`<vh>`的子节点来说，`<vh>`即被认为是`parent`
	  - 其子节点在获取数据时，可以基于`<list>`的`src`做相对路径获取。如：`<list>`的`src`给出`${list_response.items}`，那么`<vh>`中的元素就可以直接通过items中的key取得数据，而无需给出完整的绝对路径，见用法举例。
- `<footer>`
	- `<footer>` 用法同`header`节点

用法举例：
```
<list ${list_response.items}>
	<header>
		<text src="im a header"/>
	</header>
	<vh>
		<text src="${item_title}"/>
	</vh>
	<footer>
		<text src="im a footer"/>
	</footer>
</list>
```