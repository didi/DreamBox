## 如何扩展iOS动作组件-入门

iOS扩展一个动作组件，包含如下几个步骤：

1. 继承DBActions基类，并实现相关protocol方法

2. 注册自定义的动作标签

3. 编写dsl

接下来以一个简单的demo来描述`动作标签`的扩展过程，我们会在一个text组件的点击事件中，调起自定义的`动作标签`，跳转进iOS的设置页，效果如下：

![](../../assets/db_iOS_extension_04.png ':size=30%')![](../../assets/db_iOS_extension_03.png ':size=30%')

【注：可以与扩展视图组件对比：`扩展视图组件`是自定义了一个视图以及内部动作；`扩展动作组件`只是单纯的扩展了一个动作】

### 1. 继承DBActions基类，并实现相关protocol方法

定义类 `DBSettingAction` 继承至基类 `DBActions`

```
@interface DBSettingAction : DBActions
```

- 实现 `-(void)actWithDict:(NSDictionary *)dict andPathId:(NSString *)pathId` 方法，完成动作组件创建，实现动作逻辑

```
-(void)actWithDict:(NSDictionary *)dict andPathId:(NSString *)pathId{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
```

### 2. 注册自定义的动作标签

将自定义标签`DBSettingAction`注册到DreamBox，在App启动时进行注册

```
[[DBFactory sharedInstance] registActionClass:[DBSettingAction class] byType:@"openSetting"];
```

### 3. 编写dsl

上述操作向Dream Box注册了一个名为`openSetting`的动作组件，至此编写dsl时，这个动作组件就可以使用了

```xml
<dbl>
    <render>
        <text
            id="1"
            src="I am test string"
            size="12dp"
            style="blod"
            leftToLeft="parent"
            topToTop="parent"
            width="300dp"
            height="40dp"
            marginTop="50dp"
            marginLeft="50dp">
            <onClick>
                <openSetting/>
            </onClick>
        </text>
    </render>
</dbl>
```
