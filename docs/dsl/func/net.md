## `<net>`

Added in v0.1

### 设计

用于表示一次网络请求，目前仅支持`GET`方式。

### 属性

- `url` 必需。请求的API地址
- `to` 回包数据放到哪个meta数据下

### 子节点

- `<onSuccess>` 当网络请求成功，作为回调被触发，内部可再包含动作节点作为子节点
- `<onError>` 当网络请求失败（包含服务器失败和用户终端失败），作为回调被触发，内部可在包含动作节点作为子节点

### 示例

```xml
<net
    url="http://www.get-some-json-back.com"
    to="json" >
    <onSuccess>
        <trace .../>
    </onSuccess>
</net>
```