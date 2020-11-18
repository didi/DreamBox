## IOS 事件管道详细说明

### RUNTIME API设计

#### 注册监听从DB RUNTIME中发出的事件

- 方向 DB->Native (下面简写为D2N)

##### 事件管道方法定义, 方向 DB -> Native：

```xml
/**
注册D2N事件

@param eventID           事件ID
@param block             事件绑定回调
*/
-(void)registerEventWithEventID:(NSString *)eventID andBlock:(DBTreeEventBlock)block;
```

主动触发DB回调方法：

```xml
/**
native触发D2N事件携带的回调

@param callBackData           D2N事件携带的回调(透传)
@param dataStr                      N2D数据
*/
-(void)handleDBCallBack:(NSDictionary *)callBackData data:(NSString *)dataStr;
```

##### 下面是DB发送消息给Native的例子

###### *发送方：DB

```xml
<sendEvent eid="事件ID">
    <!-- msg作为子节点可以更好地承接字典数据 -->
    <msg orderId="12345" routeId="45454" />
    <callback  msgTo="meta占位">
        <!-- 动作节点 -->
    </callback>
</sendEvent>
```

###### *监听方：Native

下面是一个注册监听并执行回调的实例，主要逻辑为以下三步：
1、native侧，对DB侧发起的事件2001注册监听
2、Native监听到该事件后，进行处理，生成新数据，例newEventCbMsg
3、将接收到的callBackData，与客户端生成的新数据，一起通过回调接口传递给DB

```xml
[self.dbView registerEventWithEventID:@"2001" andBlock:^(NSString * _Nonnull evendID, NSDictionary * _Nonnull paramDict, NSDictionary * _Nonnull callbackData) {

        //客户端处理逻辑
        NSString *newEventCbMsg = @"newEventCbMsg";

        //将客户端要传递给DB的数据，与callBackData，一起传递给DB
        [self.dbView handleDBCallBack:callbackData data:newEventCbMsg];
    }];
```

#### 发送事件到DB RUNTIME

- 方向 Native -> DB (下面简写为N2D)

事件管道方法定义, 方向 Native -> DB ：

```xml
/**
发送N2D事件

@param eventID           事件ID
@param dataStr           N2D数据
*/
-(void)sendEventWithEventID:(NSString *)eventID data:(NSString *)dataStr;
```

##### 下面是Native发送消息给DB的例子：

###### *监听方：DB

```xml
<onEvent eid="事件ID" msgTo="meta占位">
    <!-- 动作节点 -->
</onEvent>
```

###### *发送方：Native

```xml
[self.dbView sendEventWithEventID:@"1000" data:@"dataString"];
```

其中@"1000" 为事件ID，@"dataString"为客户端给DB传递的数据， DB监听到Native事件后，会执行以下两个步骤：
1、将客户端给DB传递的数据@"dataString"更新到 `meta占位`对应的数据字段中
2、执行动作节点

### 实践建议

DB RUNTIME在API设计上没有支持批量的事件监听注册，原因是认为这种场景应该以多个标签扩展的形式进行扩展。框架希望在使用上，事件通信的功能只用来在特殊场景中在单个DBView领域里临时生效。另一种理解方式是：事件通讯的功能需要每次DBView的使用过程中都进行注册，而关于视图和动作的标签扩展，只需要在App初始化时进行一次即可。所以，认为事件通信的领域的临时性的，而标签扩展用来承载通用领域的诉求。