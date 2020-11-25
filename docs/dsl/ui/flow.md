## `<flow>`

Added in v0.2

### 设计

用于展示一个流式布局，是可包含视图子节点的视图节点，子视图横向依次布局，根据需要自动换行显示。

### 属性
- `src` 必需。用于代表子视图的数据源，内容必须是json（dict结构）中类型为数组的节点，以方便子view元素使用
- `hSpace` 表示子视图之间横向间距，默认是0，可设置固定值
- `vSpace` 表示子视图每一行的纵向间距，默认是0，可设置固定值

### 交互响应

无特殊

### 子节点
- 可放置 `text` `image` 等视图子节点

　　其子节点在获取数据时，可以基于`<flow>`的`src`做相对路径获取。如：`<flow>`的`src`给出`${list_response.items}`，那么`<text>`中的元素就可以直接通过items中的key取得数据，而无需给出完整的绝对路径：
```
<flow src="${list_response.items}">
	<text src="${item_title}" />
</flow>
```

#### Added in v0.3

子节点需要通过`<cell>`节点进行包裹。即：
```xml
<flow>
	<cell>
		<text />
		<text />
	</cell>
</flow>
```
