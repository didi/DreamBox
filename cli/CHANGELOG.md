# 3.1.X 主要针对节点的编译检查规则做升级
- 编译器感知所有view节点，支持外部传入view节点的扩展说明
- 编译器认为所有以`on`为开头的Tag一定是回调节点。所以，除了view节点和回调节点，其他的都认为是action节点
- 对于view和action下的callback节点一定会编译到`callbacks`的数据节点下
- 对于view的子view节点，一定会编译到`children`的数据节点下
- 其他的节点依然采用自动碰撞的逻辑
- 更改扩展配置文件的书写规则
- []在编译环节加入对节点类型规则加入强校验
- 修复action下callback编译结构错误问题
- 添加对pack节点的支持，以及对其节点DSL内容的校验规则

# 2.2.X
- 加入list和flow标签的宽高尺寸检查

# 2.1.6.X
- 自动检测DSL标签，对2.0版本DSL才支持的语法进行编译后的编译码调整，让RUNTIME正确感知兼容性
- 对未声明的自定义视图标签做显式提示
- 加入`compat-v1`命令行选项以支持强制适配v1版本的DSL
- 修复`meta`节点下声明的节点会被经过特殊节点处理的问题，支持`meta`下任意声明
- 支持在本地html调试页面中提交自定义的json数据作为`ext`数据
- DSL更新后不再重复打开web标签

# 2.1.5.X
- 支持开发者输入自定义view集合
- 支持开发者输入自定义的id索引属性集合
- 支持开发者输入被认为是view容器的自定义view节点集合
- 内置添加list、flow view标签
- 内置list、flow作为view parent标签
- view parent在编译为json的过程中会自动加入`children`字段，其value是数组，内容是child view 
- debug状态下DSL更新后httpserver会重新发布
- debug状态下DSL更新时如果遇到了编译错误不会打断整个调试进程，错误会被catch并通过日志告知
- actionAlias中的动作以内建关键字`actions`包裹为数组
- 支持对所有callback内的action做自动判定，若大于一个则自动转换为数组
- 支持通过ext yaml文件扩展接入方自己的callback
- 调试模式下自动打开web标签以展示调试信息

# 2.1.4.x
- 修复IP获取方式，使Playground可以进行本地连接
- 修正parent自动转换为0 ID的逻辑
- 修正wss存储client的ID错误问题
- 对无单位尺寸属性自动添加dp单位

# 2.1.4
- 重构编译流程，清晰化代码设计
- 升级debug状态下local http server提供的编译信息展示
- debug状态下开启了本地wss，对DSL进行监听，更新后广播通知新的编译码

# 2.x road map
- 支持debug下通过cli生成的二维码绑定做快速的开发预览
- 支持list的子节点vh的解析，视作render节点一样解析
- 支持接入方指定配置文件来告知cli哪些节点是自己新扩展的视图节点
- *支持反解查看原布局
- *支持Android、iOS工程中集成编译插件，在打包时自动对DSL文件进行编译

# 1.2
针对DB的DSL编译和Runtime适配第一版完成

# 0.2.8
- 【FIX】修复数据有效性检查的逻辑，补全对pool、ext关键字的兼容
- 【FEATURE】添加新的view标签：loading

# 0.2.7
- 【FEATURE】添加纯DSL字符串输入，以支持Web在线编译工具

# 0.2.6
- 【FEATURE】parent 的id自动转为0 并且parent和0内容的id会检测，不允许用于新id定义
- 【FEATURE】做id有效性检测，不允许重复，不允许引用落空
- 【FEATURE】id转成json时会变成自增整型数字，最大不超过65535，即0xffff，Android RUNTIME需补全前四位十六进制，不和系统冲突
- 【FEATURE】width\height为默认值时移除，即当witdh=wrap不会出现在json中
- 【FIX】检验xml前对src/srcMock中http Url做特殊字符替换
- 【FEATURE】srcMock字段会在严格模式下（release）被自动移除

```json
    "<": "&lt;",
    ">": '&gt;",
    "&": '&amp;",
    "\'": '&apos;",
    "\"": '&quot;"
```

# 0.2.5
- 【FIX】修复change-meta、action-alias等可能重复的节点编译后丢失的问题，遇到多个时转为json数组
- 【FEATURE】加入混淆功能，通过命令行`--proguard`开启，默认关闭

# 0.2.4
- meta字段的key不能包含破折号，这个不可以被自动转化，影响后边的引用，目前做报错处理
- 加入严格模式，如果DSL中对数据的引用并没有在meta中进行声明，则报错
- 加入相关有效性检查日志
- 去掉`--localserve`项，默认`--debug`为true，则提供httpserver服务
- 加入`--release`项，默认false，自动携带严格模式

# 0.2.2-3
- xml2json手写
- render节点下children全部为数组
- 所有xml node节点的key（tag）所包含的-将默认转换为_
- 所有视图节点的类型字符串转出json时放入json-object的type字段中