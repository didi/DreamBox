## 如何扩展Android动作标签-入门篇

android扩展一个动作标签，包含如下几个步骤：
1. 基类继承
2. 实现相关模板方法
3. 注册自定义的UI标签
4. 编写dsl
5. 功能实现

接下来以一个简单的demo来描述action标签的扩展过程，我们会扩展一个打开系统拨号盘的动作组件。界面上放置一个按钮，点击按钮后会打开系统拨号面板，效果如下：

![](../../assets/db_extension_06.png ':size=25%')

![](../../assets/db_extension_07.png ':size=25%')

### 1. 基类继承
定义类 `MyActionDial` 继承至基类 `DBAction`，实现构造器并实现`doInvoke`方法
```
    public MyActionDial(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {

    }
```

### 2. 实现相关模板方法
- 实现 `getNodeTag()` 方法，返回node名称，将会在dsl里使用
- 实现节点的 Creator 类，

```
public class MyActionDial extends DBAction {
	public MyActionDial(DBContext dbContext) {
	    super(dbContext);
	}
	
	@Override
	protected void doInvoke(Map<String, String> attrs) {
	
	}
	
    public static class NodeCreator implements INodeCreator {
        @Override
        public MyActionDial createNode(DBContext dbContext) {
            return new MyActionDial(dbContext);
        }
    }

    public static String getNodeTag() {
        return "dial";
    }
}
```

### 3. 注册自定义的Action标签
将自定义的Action标签注册到DreamBox，在App启动时进行注册
```
public class DemoApplication extends Application {
	......
    @Override
    public void onCreate() {
        super.onCreate();
        ......;
        DreamBox.getInstance().registerDBNode(MyActionDial.getNodeTag(), new MyActionDial.NodeCreator());
    }
}
```

### 4. 编写dsl
动作的执行需要在某个事件发生时来触发，这里我们将动作的触发放在 `单击文本` 事件里。

按照模板方法定义的节点名称编写dsl，`dial` 标签即为第2步 `getNodeTag()` 方法返回的字符串。
```
<dbl>
    <render>
        <text id="txt" src="点击打开拨号盘" size="18dp" leftToLeft="parent" rightToRight="parent" backgroundColor="#999999">
            <onClick>
                <dial />
            </onClick>
        </text>
    </render>
</dbl>
```

如果此时调试查看节点树，会发现自定义的 `dial` 节点已经在其中了

![](../../assets/db_extension_08.png ':size=35%')

### 5. 功能实现
接下来完成细节功能的实现

#### 5.1 动作处理
要想在某个事件发生时执行某个动作，需要覆写父类的 `doInvoke` 方法。参数`attrs`里是`dial`节点的属性集合
```
public class MyActionDial extends DBAction {
	......
	@Override
	protected void doInvoke(Map<String, String> attrs) {
	
	}
	......
}
```

点击文本按钮 `doInvoke` 方法会被触发，可在此方法里执行业务相关的逻辑。

#### 5.2 属性处理
通过给 `MyActionDial` 添加一个 phoneNumber 属性，来展示属性的扩展, `phoneNumber` 属性用于定义电话号码，会传到拨号盘。

```
<dbl>
    <render>
        <text id="txt" src="点击打开拨号盘" size="18dp" leftToLeft="parent" rightToRight="parent" backgroundColor="#999999">
            <onClick>
                <dial phoneNumber="13512345678" />
            </onClick>
        </text>
    </render>
</dbl>
```

Java侧扩展组件代码，如下
```
public class MyActionDial extends DBAction {
    public MyActionDial(DBContext dbContext) {
        super(dbContext);
    }

    @Override
    protected void doInvoke(Map<String, String> attrs) {
        MyDemo.getInstance().showDialPanel(mDBContext.getContext(), attrs.get("phoneNumber"));
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public MyActionDial createNode(DBContext dbContext) {
            return new MyActionDial(dbContext);
        }
    }

    public static String getNodeTag() {
        return "dial";
    }
}
```

```
public class MyDemo {
    //创建 SingleObject 的一个对象
    private static MyDemo instance = new MyDemo();

    //让构造函数为 private，这样该类就不会被实例化
    private MyDemo() {
    }

    //获取唯一可用的对象
    public static MyDemo getInstance() {
        return instance;
    }

    public void showDialPanel(Context context, String phoneNumber) {
        Intent intent = new Intent(Intent.ACTION_DIAL);
        intent.setData(Uri.parse("tel:" + phoneNumber));
        context.startActivity(intent);
    }
}

```

以上是android组件扩展的入门篇，以一个简单的小例子引领使用者快速理解一些基本概念。