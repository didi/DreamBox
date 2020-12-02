## 如何扩展iOS视图组件-入门

iOS扩展一个视图组件，包含如下几个步骤：

1. 继承view基类，并实现相关protocol方法
2. 继承model基类，并实现相关protocol方法
3. 为自定义的标签注册对应view与model
4. 编写dsl

接下来以一个简单的demo来描述视图标签的扩展过程，我们会扩展一个打开带有一个按钮的视图组件，点击按钮后弹出alert弹窗展示dsl中携带的数据

![](../../assets/db_iOS_extension_02.png ':size=40%')
![](../../assets/db_iOS_extension_01.png ':size=30%')

### 1. 继承DBTreeView基类，并实现相关protocol方法

定义类 `DBTestExtensionView` 继承至基类 `DBTreeView`

```
@interface DBTestExtensionView : DBTreeView
```

- 实现 `-(**void**)setDataWithModel:(DBViewModel *)model andPathId:(NSString *)pathId` 方法，完成视图内容以及逻辑创建

```
-(void)setDataWithModel:(DBViewModel *)model andPathId:(NSString *)pathId {

    _model = (DBTestExtensionModel *)model;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"点击我" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    button.frame = CGRectMake(50, 0, 200, 30);
}

- (void)clicked:(UIButton *)button {
    [[[UIAlertView alloc] initWithTitle:@"dsl携带数据：" message:[NSString stringWithFormat:@"%@", _model.testString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}
```

### 2. 继承DBViewModel基类，并实现相关protocol方法

定义类 `DBTestExtensionModel` 继承基类 `DBViewModel`，在自定义的model类中，可以增加自定义的属性，例如下例中的 `testString`

```
@interface DBTestExtensionModel : DBViewModel
@property (nonatomic, copy) NSString *testString;

@end
```

- 实现 `+ (DBViewModel *)modelWithDict:(NSDictionary *)dict` 方法，完成model创建以及自定义属性的赋值

```
+ (DBViewModel *)modelWithDict:(NSDictionary *)dict{
    DBTestExtensionModel *model = (DBTestExtensionModel *)[super modelWithDict:dict];
    model.testString = [dict objectForKey:@"testString"];
    return model;
}
```

### 3. 为自定义的标签注册对应view与model

将自定义标签`extensionTestView`对应的view与model，注册到DreamBox，在App启动时进行注册

```
[[DBFactory sharedInstance] registViewClass:[DBTestExtensionView class] byType:@"extensionTestView"];

[[DBFactory sharedInstance] registModelClass:[DBTestExtensionModel class] byType:@"extensionTestView"];
```

### 4. 编写dsl

上述操作向Dream Box注册了一个名为`extensionTestView`的组件，至此编写dsl时，这个组件就可以使用了

```xml
<dbl>
    <render>
        <extensionTestView
            id="1"
            testString="I am test string"
            leftToLeft="parent"
            topToTop="parent"
            width="300dp"
            height="40dp"
            marginTop="50dp"
            marginLeft="50dp"/>
    </render>
</dbl>
```
