Tag Roadmap:

### `<list>`

- `pullRefresh` 是否支持下拉刷新，值为布尔值
- `loadMore` 是否支持底部加载更多，值为布尔值
- `pageIndex` 表示当前页面的索引值，配合`loadMore`使用，值为字符串，指向`meta`中的某个变量，此变量只能存储整型数据，在加载更多执行后此值会被SDK执行+1操作

### `<progress>`

- `barBgColor` 横向进度条的底层颜色，自动拉伸
- `barFgColor` 横向进度条的顶部颜色，表示当前进度，自动拉伸
- `radius` 进度条矩形圆角半径
