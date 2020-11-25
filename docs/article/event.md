## 1. 什么是事件管道

本文章讲述了`DreamBox`事件管道相关的内容，阅读前需要对`DreamBox`有基本了解

### 1.1 概念

考虑一个问题，开发者在使用`DreamBox`时，有些逻辑的处理需要在native环境里实现，处理完的结果需要再传递给`DreamBox`。此时在`DreamBox`和`native`之间需要一个机制来实现这种通讯能力，这个机制在DreamBox里就是 [事件管道](../extension/event/event_pipe.md)。

目前常用的跨端实现方案H5、weex、RN都提供了可以和native双向通信的能力。

### 1.2 使用场景

举几个典型场景的case，实际项目中可根据需要灵活使用：

1. PopupWindow里采用DreamBox实现弹窗，点击DreamBox界面里某个元素，关闭PopupWindow弹窗
2. 页面采用Native和DreamBox混合布局，点击DreamBox界面里某个元素或某个事件发生时执行1至多个Action
   - 执行DreamBox默认提供的Action，例：请求网络、上报埋点、存储KV等
   - 执行开发者自己扩展的Action
3. 页面采用Native和DreamBox混合布局，点击Native某个元素或某个事件发生，刷新DreamBox整个页面或页面里某个UI组件

## 2. 如何使用

下面通过示例来说明下`事件管道`的使用，示例:

- [Android 工程代码](https://static.didialift.com/pinche/gift/resource/75ct43r4o28-1600680539525-DBEventDemo.zip)
- [IOS 工程代码](https://static.didialift.com/pinche/gift/resource/gs6ioeb4li8-1600686674484-dreambox_ios.zip)

为了便于后面内容的理解，强烈建议把工程<font color='red'>run起来...run起来...run起来...</font> 简单起见，示例的DreamBox模板会采用本地方式加载，本地加载方式的使用方式可参考DreamBox gitbook的 [快速入门](../use/start.md)

### 2.2 Native向DreamBox发送事件

#### 2.2.1 示例

下图演示Native向DreamBox发送事件

<center class="half">
    <img style="border:2px solid black" src="http://img-hxy021.didistatic.com/static/km/do1_iU6ZcCzJGYQKy2nT5sGL" width="380"/>
</center>

- 深绿色背景容器是DreamBox容器(debug环境右上角会有一个角标)，容器里有一个TextView
- 深灰色背景按钮是native的TextView [click me]
- 点击[click me]，DreamBox容器里的TextView文案会每次加1

#### 2.2.2 dsl模板

实现上述效果，首先需要编写DreamBox模板入下：

```
<dbl xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <meta>
        <eventData testData="Native To DreamBox" />
    </meta>
    <onEvent eid="1000" msgTo="eventData">
        <toast src="${eventData.toast}" />
    </onEvent>
    <render>
        <text bottomToBottom="parent" changeOn="eventData" color="#FFFFFF" height="wrap" leftToLeft="parent"
            rightToRight="parent" size="20dp" src="${eventData.testData}" topToTop="parent" width="wrap" />
    </render>
</dbl>
```

- 根节点dbl里包含数据池节点`meta`，native事件监听节点`onEvent`，渲染节点`render`
- `meta`数据池里默认有一个数据源`eventData`
- `render`节点里是`text`节点

#### 2.2.2 native事件监听

重点关注下面这段DSL

```
<dbl>
    ......
    <onEvent eid="1000" msgTo="eventData">
        <toast src="${eventData.toast}" />
    </onEvent>
    ......
</dbl>
```

当DreamBox接收到一个native发送过来的事件，先判断事件id是否为1000，如果事件id为1000，会将处理该事件。具体会做两个事情：

- 如果事件携带了数据过来，会将数据放入meta数据池的`msgTo`指定的节点下。本例为放到`eventData`节点下
- 执行`toast` action，toast `src` 使用的数据源为事件携带过来的数据。数据取用方式为`${eventData.xxx}`

数据相关概念参考 [meta节点](../dsl/meta.md) 以及 工作原理 [数据](../design/data.md) 一节

#### 2.2.3 文案刷新

再来关注下面这段DSL

```
<dbl>
    ......
    <render>
        <text bottomToBottom="parent" changeOn="eventData" color="#FFFFFF" height="wrap" leftToLeft="parent"
            rightToRight="parent" size="20dp" src="${eventData.testData}" topToTop="parent" width="wrap" />
    </render>
    ......
</dbl>
```

- text 的 `src`属性指定为`eventData.testData`，即text的文案默认为`Native To DreamBox`
- text 的 `changeOn`属性指定为`eventData`，即`eventData`发生改变时会刷新text显示文案

#### 2.2.4 模板加载及事件发送

本小结涉及Android和IOS两个平台代码示例，将分别展示

##### 2.2.4.1 Android

assets目录有编译后的模板`local.event_demo_1.dbt`，下面的代码用来加载模板，发送事件

```
class MainActivityKt : AppCompatActivity() {
    ......
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        // event Native To DreamBox
        val dbView1 = findViewById<DreamBoxView>(R.id.db_container_1)
        // 调用DreamBox容器实例的render方法进行渲染
        dbView1.render(DemoApplication.ACCESS_KEY, "event_demo_1", null)
        val txtClick = findViewById<TextView>(R.id.txt_click)
        // 向DreamBox发送事件
        txtClick.setOnClickListener { dbView1.sendEvent("1000", getNToDCountJson()) }
        ......
    }

    private fun getNToDCountJson(): String? {
        return "{\"toast\":\"Native to DreamBox event\",\"testData\": \"Native To DreamBox: ${countNToD++}\"}"
    }
    ......
}
```

- 将dsl模板编译后，复制编译码，保存为`local_event_demo_1.dbt`放入assets目录
- 调用DreamBox容器实例的render方法进行渲染
- 调用DreamBox容器实例的`sendEvent`方法，事件id`1000`和模板里对应起来
  - dbView1.sendEvent("1000", getNToDCountJson());
  - 模板里的onEvent节点定义了如何处理这个id为1000的事件，具体为：
    - 弹一个toast
    - 改变meta池的eventData节点，同时text由于监听了eventData的变化，所以文案会发生变化

##### 2.2.4.2 IOS

工程目录有编译后的模板`local.event_demo_1.dbt`，下面的代码用来加载模板，发送事件

    - (void)createDBView1 {
        //解析dict
        self.dbView = [[DBTreeView alloc] init];
        [self.dbView loadWithTemplateId:@"event_demo_1" accessKey:@"DEMO" extData:nil completionBlock:nil];
        [self.view addSubview:self.dbView];
        [self.dbView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(50);
            make.left.right.equalTo(self.view);
            make.height.equalTo(self.view).dividedBy(5);
        }];
        self.dbView.backgroundColor = [UIColor db_colorWithHexString:@"4eac7c"];
    }   

- 将dsl模板编译后，复制编译码，保存为`local_event_demo_1.dbt`放入assets目录
- 调用DreamBox容器实例的loadWithTemplateId:accessKey:extData:completionBlock:方法,进行渲染
- 调用DreamBox容器实例的`sendEvent`方法，事件id`1000`和模板里对应起来
  - [self.dbView sendEventWithEventID:@"1000" data:newEventCbMsg];
  - 模板里的onEvent节点定义了如何处理这个id为1000的事件，具体为：
    - 弹一个toast
    - 改变meta池的eventData节点，同时text由于监听了eventData的变化，所以文案会发生变化

### 2.3 DreamBox向Native发送事件

#### 2.3.1 示例

下图演示DreamBox向Native发送事件，Native接收事件并处理完后会回调DreamBox

<center class="half">
    <img style="border:2px solid black" src="http://img-hxy021.didistatic.com/static/km/do1_kZPHXUiE7rw3dLqRqNJ9" width="380"/>
</center>

- 同样，深绿色背景容器是DreamBox容器，容器里有一个TextView [click me]
- DreamBox容器下面是一个native TextView
- 单击DreamBox容器里的[click me]，native TextView文案会加1
- 数字加1后，Native回调DreamBox，并显示在DreamBox容器右下角

接下来，我们会借助这个简单的小demo，来讲述DreamBox事件管道所涉及的基本概念。

#### 2.3.2 dsl模板

实现上述效果，首先需要编写DreamBox模板入下：

```
<dbl xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <meta>
        <eventData testDataCallback="Callback" />
    </meta>
    <render>
        <text backgroundColor="#666666" bottomToBottom="parent" color="#FFFFFF" gravity="center" height="50dp"
            leftToLeft="parent" rightToRight="parent" size="20dp" src="click me" topToTop="parent" width="200dp">
            <onClick>
                <sendEvent eid="2000">
                    <msg testData="DreamBox To Native: " />
                    <callback msgTo="eventData">
                        <toast src="${eventData.toast}" />
                    </callback>
                </sendEvent>
            </onClick>
        </text>
        <text bottomToBottom="parent" changeOn="eventData" color="#FFFFFF" marginBottom="20dp" marginRight="5dp"
            rightToRight="parent" src="${eventData.testDataCallback}" />
    </render>
</dbl>
```

- 根节点dbl里包含数据池节点`meta`，渲染节点`render`
- `meta`数据池里默认有一个数据源`eventData`
- `render`节点里有2个`text`节点，第一个text单击时会向native发送event

#### 2.3.3 发送事件给native

重点关注下面这段DSL

```
<dbl>
    ......
        <onClick>
            <sendEvent eid="2000">
                <msg testData="DreamBox To Native: " />
                ......
            </sendEvent>
        </onClick>
    ......
</dbl>
```

点击DreamBox里的text组件，会向native发送一个事件

- 事件id为2000
- 携带一个json数据 `testData`

#### 2.3.4 模板加载及事件接收

本小结涉及Android和IOS两个平台代码示例，将分别展示

##### 2.3.4.1 Android

assets目录有编译后的模板`local.event_demo_2.dbt`，下面的代码用来加载模板，注册事件处理对象

```
class MainActivityKt : AppCompatActivity() {
    ......
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        ......
        // event D TO N
        val txtMsg = findViewById<TextView>(R.id.txt_msg)
        val dbView2 = findViewById<DreamBoxView>(R.id.db_container_2)
        // 调用DreamBox容器实例的render方法进行渲染
        dbView2.render(DemoApplication.ACCESS_KEY, "event_demo_2", null)
        // 调用DreamBox容器实例的registerEventReceiver方法注册事件
        dbView2.registerEventReceiver("2000") { msg, callback ->
            countDToN++
            txtMsg.text = msg["testData"].asString + countDToN
            callback?.onCallback(getDToNCountJson())
        }
    }
    ......
    private fun getDToNCountJson(): String? {
        return "{\"toast\":\"DreamBox To Native Event\",\"testDataCallback\": \"[Callback]: ${++countDToN}\"}"
    }
}
```

- 将dsl模板编译后，复制编译码，保存为`local_event_demo_2.dbt`放入assets目录
- 调用DreamBox容器实例的`registerEventReceiver`方法，注册事件id为`2000`回调处理实现。事件id和模板里对应起来，收到dreambox发送来的事件后做如下处理
  - 事件id是否为2000，是则进行处理
  - refresh textview的文案
  - 回调DreamBox并携带一个json数据

##### 2.3.4.2 IOS

工程目录有编译后的模板`local.event_demo_2.dbt`，下面的代码用来加载模板，注册事件处理对象

```
- (void)createDBView2 {
    NSDate *begin = [NSDate date];
    //解析dict
     self.dbView2 = [[DBTreeView alloc] init];
    [self.dbView2 loadWithTemplateId:@"event_demo_2" accessKey:@"DEMO" extData:nil completionBlock:nil];
    [self.view addSubview:self.dbView2];
    [self.dbView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.height.equalTo(self.view).dividedBy(5);
    }];
    self.dbView2.backgroundColor = [UIColor db_colorWithHexString:@"4eac7c"];;
    NSDate *end = [NSDate date];
    NSTimeInterval deltaTime = [end timeIntervalSinceDate:begin];
    NSLog(@"耗时：%fms", deltaTime*1000);
    [self.dbView2 registerEventWithEventID:@"2000" andBlock:^(NSString * _Nonnull evendID, NSDictionary * _Nonnull paramDict, NSDictionary * _Nonnull callbackData) {
        
        self.count2++;
        NSString *countStr = [NSString stringWithFormat:@"DB to Native 计数 %ld", self.count2];
        _NativeLab.text = countStr;
        //客户端处理逻辑
        NSString *cbCountStr = [NSString stringWithFormat:@"DB to Native call back 计数 %ld", self.count2];
        NSDictionary *newEventCbMsg = @{
            @"testDataCallback": cbCountStr
        };
        
        //将客户端要传递给DB的数据，与callBackData，一起传递给DB
        [self.dbView2 handleDBCallBack:callbackData data:newEventCbMsg];
    }];
}
```

- 将dsl模板编译后，复制编译码，保存为`local_event_demo_2.dbt`放入工程目录
- 调用DreamBox容器实例的`registerEventWithEventID:andBlock:`方法，注册事件id为`2000`回调处理实现。事件id和模板里对应起来，收到dreambox发送来的事件后做如下处理
  - 事件id是否为2000，是则进行处理
  - refresh textview的文案
  - 回调DreamBox并携带一个json数据

#### 2.3.5 回调事件处理

```
<dbl>
    ......
        <callback msgTo="eventData">
            <toast src="${eventData.toast}" />
        </callback>
    ......
</dbl>
```

native在收到事件并处理后执行了回调，DreamBox执行如下处理

- 将回调携带的数据更新到数据池的`eventData`节点
- 弹一个toast，toast内容为eventData对象的toast属性

#### 2.3.6 回调文案刷新

再来关注下面这段DSL

```
<dbl>
    ......
    <render>
        ......
        <text bottomToBottom="parent" changeOn="eventData" color="#FFFFFF" marginBottom="20dp" marginRight="5dp"
            rightToRight="parent" src="${eventData.testDataCallback}" />
    </render>
    ......
</dbl>
```

- text 的 `src`属性指定为`eventData.testDataCallback`，即text的文案默认为`[[D TO N] 计数 callback`
- text 的 `changeOn`属性指定为`eventData`，即`eventData`发生改变时会刷新text显示文案
- callback时携带的数据更新了`eventData`，所以会刷新文案
