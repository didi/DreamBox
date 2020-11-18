## Android 事件管道详细说明
下面详细说明下 RUNTIME API 的设计，及用法示例

### 事件管道方法定义
- 方向 DB -> Native(下面简写为D2N)：

`dbCoreView` 是 `IDBCoreView` 的实例
```xml
/**
 * 注册D2N事件
 * @param eid           事件ID
 * @param eventReceiver 事件绑定回调
 */
void registerEventReceiver(String eid, IDBEventReceiver eventReceiver);
```

#### 下面是DB发送消息给Native的例子

- 发送方：DB，点击图片会发送事件到native
```xml
<dbl>
    <render>
        <image id="img" leftToLeft="parent" rightToRight="parent"
            src="https://static.didialift.com/pinche/gift/resource/4f5opuqr4do-1594029757807-carDetect.gif"
            topToTop="parent" width="200dp">
            <onClick>
                <sendEvent eid="2001">
                    <msg orderId="123456" routeId="654321" />
                    <callback msgTo="eventCbMsg">
                        <toast src="${eventCbMsg.student.class.className}" />
                        <log level="d" src="${eventCbMsg.student.class.className}" />
                    </callback>
                </sendEvent>
            </onClick>
        </image>
    </render>
</dbl>
```

- 监听方：Native

下面是一个注册监听并执行回调的实例，主要逻辑为以下三步：
1. native侧，对DB侧发起的事件2001注册监听
2. Native监听到该事件后，进行处理，生成新数据，例newEventCbMsg
3. 将接收到的callBackData，与客户端生成的新数据，一起通过回调接口传递给DB

```xml
// 注册D2N事件
dbCoreView.registerEventReceiver("2001", new IDBEventReceiver() {
	@Override
	public void onEvent(JsonObject msg, Callback callback) {
		Log.d("TMP_TEST", "msg: " + msg);
		String extJson = "{\"student\": {\"name\":\"小张\", \"age\":\"16\", \"class\": {\"className\": \"一班\"}}}";
		callback.onCallback(extJson); // 主动触发DB回调方法
	}
});
```

### 发送事件到 DB RUNTIME

- 方向 Native -> DB (下面简写为N2D)

事件管道方法定义, 方向 Native -> DB ：

```xml
/**
 * 发送N2D事件
 * @param eventID           事件ID
 * @param dataStr           N2D数据
 */
void sendEvent(String eid, String msgTo);
```

#### 下面是Native发送消息给DB的例子：

- 监听方：DB

```xml
<dbl>
    <meta eventCbMsg="null" eventOn="null" />
    <onEvent eid="1000" msgTo="eventOn">
        <toast src="${eventOn.student.name}" />
    </onEvent>
    <render>
        ......
    </render>
</dbl>
```

- 发送方：Native

```xml
String extJson = "{\"student\": {\"name\":\"小张\", \"age\":\"16\", \"class\": {\"className\": \"一班\"}}}";
dbViewTest.sendEvent("1000", extJson);
```

其中"1000" 为事件ID，"extJson"为客户端给DB传递的数据， DB监听到Native事件后，会执行以下两个步骤：
1、将客户端给DB传递的数据"extJson"更新到 `meta占位`对应的数据字段中
2、执行动作节点

### 实践建议

DB RUNTIME在API设计上没有支持批量的事件监听注册，原因是认为这种场景应该以多个标签扩展的形式进行扩展。框架希望在使用上，事件通信的功能只用来在特殊场景中在单个DBView领域里临时生效。另一种理解方式是：事件通讯的功能需要每次DBView的使用过程中都进行注册，而关于视图和动作的标签扩展，只需要在App初始化时进行一次即可。所以，认为事件通信的领域的临时性的，而标签扩展用来承载通用领域的诉求。