## 如何扩展Android UI标签-入门篇

android扩展一个UI标签，包含如下几个步骤：
1. 基类继承
2. 实现相关模板方法
3. 注册自定义的UI标签
4. 编写dsl
5. 功能实现

接下来以一个简单的demo来描述UI标签的扩展过程，我们会扩展一个编辑框UI标签组件，然后在界面上放置两个扩展的编辑框，一个输入一些文字，另一个显示hint提示

![](../../assets/db_extension_04.png ':size=30%')

### 1. 基类继承
定义类 `MyEditView` 继承至基类 `DBBaseView`，基类需要提供一个native标签实现类作为泛型参数，这里只是简单演示，所以使用了系统自带的 EditText 作为标签的实现类。
```
public class MyEditView extends DBBaseView<View> {
}
```

### 2. 实现相关模板方法
- 实现构造方法
- 实现 `getNodeTag()` 方法，返回node名称，将会在dsl里使用
- 实现节点的 Creator 类，

```
public class MyEditView extends DBBaseView<View> {
    protected MyEditView(DBContext dbContext) {
        super(dbContext);
    }
	
    public static String getNodeTag() {
        return "edit_view";
    }

    public static class NodeCreator implements INodeCreator {
        @Override
        public MyEditView createNode(DBContext dbContext) {
            return new MyEditView(dbContext);
        }
    }
}
```

### 3. 注册自定义的UI标签
将自定义的UI标签注册到DreamBox，在App启动时进行注册
```
public class DemoApplication extends Application {
	......
    @Override
    public void onCreate() {
        super.onCreate();
        ......
        DreamBox.getInstance().registerDBNode(MyEditView.getNodeTag(), new MyEditView.NodeCreator());
    }
}
```

### 4. 编写dsl
按照模板方法定义的节点名称编写dsl，`edit_view` 标签即为第2步 `getNodeTag()` 方法返回的字符串
```
<dbl>
    <render>
        <text id="txt" src="text-扩展测试" backgroundColor="#999999" />
        <edit_view width="200dp" topToBottom="txt" marginTop="10dp" />
    </render>
</dbl>
```

如果此时调试查看节点树，会发现自定义的edit_view节点已经在其中了

![](../../assets/db_extension_01.png ':size=35%')


### 5. 功能实现
接下来完成细节功能的实现

#### 5.1 渲染处理
要想将View显示到界面上，需要覆写父类的如下两个方法:
- `onCreateView`，此方法主要是返回一个继承自View类的实例
- `onAttributesBind`，此方法的参数是dsl里<edit_view/>标签所有属性的集合

```
public class MyEditView extends DBBaseView<View> {
    protected MyEditView(DBContext dbContext) {
        super(dbContext);
    }
	
    @Override
    protected View onCreateView() {
        return new EditText(mDBContext.getContext());
    }

    @Override
    protected void onAttributesBind(Map<String, String> attrs) {
		super.onAttributesBind(attrs);
    }

    ......
}
```
这里以系统原生的 `EditText` 作为View对象返回，也可以实现自己的EditText组件。返回的EditText实例，框架会将它添加到父布局里。

此时通过 LayoutInspector 工具查看UI树，能看到EditText已经在UI树里了，运行程序已经可以查看到效果。点击输入框输入 `Hello EditorText`，得到如图效果

![](../../assets/db_extension_02.png ':size=35%')

![](../../assets/db_extension_03.png ':size=35%')

#### 5.2 属性处理
通过给MyEditText添加一个hint效果，来展示属性的扩展。

先在dsl里新添加一个MyEditText组件，并新增属性 `hint` 赋值为 hello hint
```
<dbl>
    <render>
        <text id="txt" src="text-扩展测试" backgroundColor="#999999" />
        <edit_view id="edit" width="200dp" topToBottom="txt" marginTop="10dp />
        <edit_view width="200dp" topToBottom="edit" marginTop="10dp" hint="hello hint" />
    </render>
</dbl>
```

Java侧扩展组件完整代码，如下
```
public class MyEditView extends DBBaseView<View> {
    protected MyEditView(DBContext dbContext) {
		super(dbContext);
	}

	@Override
	protected View onCreateView() {
		return new EditText(mDBContext.getContext());
	}

	@Override
	protected void onAttributesBind(Map<String, String> attrs) {
		super.onAttributesBind(attrs);

		((EditText) mNativeView).setText(attrs.get("hint"));
	}

	public static String getNodeTag() {
		return "edit_view";
	}

	public static class NodeCreator implements INodeCreator {
		@Override
		public MyEditView createNode(DBContext dbContext) {
			return new MyEditView(dbContext);
		}
	}
}
```

![](../../assets/db_extension_05.png ':size=30%')

以上是android组件扩展的入门篇，以一个简单的小例子引领使用者快速理解一些基本概念。