By方绍晟、李泽琛

本文章讲述了`DreamBox`数据相关的内容，阅读前需要对`DreamBox`有基本了解

-------------

### 1.元数据节点meta
```xml
<dbl>
    <meta
        src1="hello world!"
        src2="true"
    /meta>
    <render>
    ...
    </render>
</dbl>
```

在 DreamBox 中的 meta 节点，代表当前 dbView 的数据池。每个 dbView 有且仅有自己的唯一一份数据池。dbView 中视图渲染、动作节点所需要的数据都是从meta中获取，meta 可以类比为一个 **JsonObject** ，但是其中的键值 `ext` 与 `pool` 作为DreamBox内部字段有特殊用法。

##### 1.1读取meta节点数据
可以在需要数据的地方使用 `${name}` 的形式来获取数据，其数据类型一般是 `Boolean` 、`Int` 、`String`，甚至是一个 `JsonObject`。

````xml
<dbl>
    <meta name="LiLei" />
    <render>
        <text src="${name}" ... />
    </render>
</dbl>
````
![LiLei](https://static.didialift.com/pinche/gift/resource/jknldvs2em8-1601282254654-ll.png)

当然也可以采用 `${parent.level1.level2}` 通过 `.` 来获取嵌套数据。

````xml
<dbl>
	<meta> 
	    <person name="HanMeiMei"/> 
	</meta>
	<render>
	    <text src="${person.name}" .../>
	</render>
</dbl>
````
![HanMeiMei](https://static.didialift.com/pinche/gift/resource/jtaqtjn9tf-1601282254134-hmm.png)

考虑到使用场景较小，且使用起来会有歧义，对于 `JsonArray` 无法简单通过 ~~${childs[0]}~~ 这种方式处理。但是可以通过诸如列表视图来使用 `JsonArray` 数据。

```` xml
<dbl>
    <meta />
    <render>
        <list src="${ext.db_list}" ...>
            <header>
                <text src="I'm header View" .../>
            </header>
            <vh>
                <view .../>
                <image src="${img}" .../>
                <text src="${title}" .../>
                <text src="${subtitle}" .../>
                <image src="${arrow}" .../>
            </vh>
            <footer >
                <view id="line" .../>
                <text src="I'm footer View" .../>
            </footer>
        </list>
    </render>
</dbl>

````
```` json
//ext数据
{
    "db_list": [
        {
            "img": "https://static.didialift.com/pinche/gift/resource/b78l9o67vr4-1594955096192-qian.png",
            "title": "主标题主标题",
            "subtitle": "这是一段描述，Yahaha",
            "arrow":"https://static.didialift.com/pinche/gift/resource/nm78nn24srg-1596768708081-bts_home_ctr_top_content_arrow.png"
        },
        ...
    ]
}
````
![list](https://static.didialift.com/pinche/gift/resource/g1lcoag50qo-1601002681234-ListY.png)


##### 1.2设置meta节点数据
最简单的方式是直接在 dbView 的 `meta` 节点中进行设置，这种xml的写法，会最终被编译成对应json的格式，依赖这个特性，可以在meta节点中写下任意的json数据(比如json数组，json嵌套)

```` xml
//xml
<meta>
 	<person>
   		 <dog name="kiki" />
	</person>
</meta>

````

```` json
//json
"meta": {
"person": {
	"dog": {
 		"name": "kiki"
	}
}
````

一般来说，我们通过网络请求（ [动作节点`<net>`](../dsl/func/net.md) ），或自定义事件（ [事件管道`<sendEvent>`、`<onEvent>`](../extension/event/event_pipe.md) ）等方式与外界交互，最终会获取一些数据，这些新数据便可以存放在 `meta` 数据池中，供 DreamBox 使用。

```` xml
<net url="xxx" to="net_result" >
	<onSuccess>
   		 <toast src="数据获取成功" />
	</onSuccess>
	<onError>
   		 <toast src="网络数据获取失败" />
	</onError>
</net>
````

而在db内可以直接通过动作节点来更改 meta 中的数据（ [动作节点`<changeMeta>`](../dsl/func/changeMeta.md) ）。

```` xml
<dbl>
    <meta confirm="我是变更前的数据:1234567" />
    <render>
        <text src="click me,变更数据" >
            <onClick>
                <changeMeta key="confirm" value="我是变更后的数据:7654321" />
            </onClick>
        </text>
        <text src="${confirm}" changeOn="confirm">
        </text>
    </render>
</dbl>

````

通过数据的变化，结合 [`changeOn`](../dsl/root.md) 方式，便可以做到页面的刷新，更新ui展示。


### 2.全局数据池pool
虽然大多数情况，很多功能靠 dbView 本身就可以完成，类似一个轻量级 h5 页，但是也会遇到跟h5同样的问题：作为一个相对独立的页面很难了解当前应用状态。比如当前是否登录（`login`）、用户的角色类型，或者手机系统版本，而这些全局数据必须依赖宿主 App 提供。


考虑到这些场景，在db内建立了一个全局数据池 `pool`，用于存储这些应用或业务相关的全局数据。`pool` 需要宿主在合适时机将数据注入到 DreamBox 中，比如登录登出时，或者断网恢复时等场景。而在 dbView 内部，则 `pool` 作为特殊关键值存放在每个 dbView 的 `meta` 数据池中，想获取这些数据，可以使用`${pool.login}`。（ `pool` 仅支持设置一层节点 ）

``` java
// java
DreamBox.getInstance().putPoolData("accessKey", "login", "loginId");
```

``` Objc
// Objc
[[DBPool shareDBPool] setObject:dict ToDBGlobalPoolWithAccessKey:@"accessKey"];
```


### 3.模板数据ext

试想一种场景，客户端同在做页面的优化迭代，比如升级为`RN`、`Flutter`，在这个情况下只需要端上的代码变更，而与 api 的数据交互是不需要改动的。

同样在 DreamBox 的使用中。因为 DreamBox 相对灵活，所以小到一个卡片也可使用 DreamBox 替换。 而卡片数据是从 api 的下发结构中获取的。为了保持新动态页面的独立，一般会考虑使用新接口，但若真的去新建接口，会造成接口冗余而且成本过高。其实对于这种场景，只需要将数据注入到新的 dbView 即可。`ext` 的概念便是为此而生。


`ext` 可以接受任意的 `JsonObject` 数据，然后在db渲染时传入，这样在db中便可以获取到，通过 `${ext.name}`。


````objc
NSDictionary *ext;
[DBTreeView loadWithTemplateId:tid accessKey:kAccesskey extData:ext completionBlock:^(BOOL successed, NSError * _Nullable error) {
    
}];
````
````java
// DreamBoxView
public void render(String accessKey, String templateId, String extJsonStr){}
````

但需要注意，`ext` 与 `pool` 不同，`ext` 是与页面相关的，每个 dbView 都可以在渲染时传入 `ext` 数据，而 `pool` 作为一个全局数据，是所有 dbView 都能获取的。


### 总结
每个app可以拥有N个AccessKey，每个AccessKey可以代表一个业务线，在每个AccessKey内部的`pool`和`meta`的关系如下图所示。每个Meta内部含有`ext`数据，用于额外的数据输入

![多个accessKey表现](https://static.didialift.com/pinche/gift/resource/31qo3ucvdb8-1601277854196-DataPool_app.png)
### 数据的接入实践

如果了解了 `ext` 的产生背景，那么会很自然想到一种场景: 客户端与 api 协议商量好，但是版本迭代过程需求有变化，比如新增标识或更改页面展示。但哪怕只是小的改动，涉及协议变化，也需要通过客户端进行发版来处理。所以为了保证扩展性，对协议增加保留字段便是一种动态化的手段。

当然如果 DreamBox 直接与 Api 进行交互，那双方自然可以随时修改协议。但如果 DreamBox 使用的是页面整体数据的一部分，就会用到提前预埋的保留字段。

增加保留字段这个概念不是 DreamBox 中包含的，而是在接入时可以采用的最佳实践。在顺风车业务使用时，我们使用了名称为 `dbd` 的字段作为保留字段，在平时的版本开发中，并不需要使用 `dbd` 字段，只要保证在传入的 `ext` 数据中可以存在 `dbd` 字段的扩展，而一旦有需求需要兼容旧版本，便可以使用 `dbd` 字段，然后更新对应的 `db模板`，以此响应需求。

### 其他
[DreamBox开发手册](../use/README.md)