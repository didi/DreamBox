## 命令行工具使用说明

### 安装

详见[环境准备](environment.md)

### 使用

> 假设你的DSL命名为`demo.xml`

#### 0. 帮助

```
dmb-cli -h
```
具体参数细节以上述命令的输出为准。

#### 1. 用于调试

```
dmb-cli demo.xml
```
如果需要在终端中展示详细的信息可以加参数`--verbose`，此时，命令行默认认为是在调试状态下：
- 会发布本地的http server告知相关调试信息（包含编译码及中间态的Json码）
- 会发布本地websocket server，并将二维码发布在上一项提供的html中，开发者可以通过Playground App或调试入口扫码绑定手机上的DBView
- 会监听`demo.xml`，当内容发生变化时重新编译并在Playground App或你的接入App中使DBView效果实时更新

#### 2. 用于发布

```
dmb-cli demo.xml --release
```

在终端中会直接产出`编译码`，默认的会进行混淆和强制检查

- `nocheck` 可以强制关闭检查
- `noproguard` 可以强制关闭混淆

### 扩展支持

CLI支持接入方通过命令行中`--extcfg`参数后传入`yaml`格式配置文件的方式，让编译器支持编译接入方自行扩展的UI或动作标签

### 配置文件编写方式

示例：
```yaml
ext:
  views: customViewA
  idref_attrs: parentId
  actions: customActionA

```

#### ext
考虑到配置文件将来可能承载扩展功能之外的配置参数，所以`ext`视为扩展相关参数的开始标签，必须存在

内部参数说明：
1. `views` 告知编译器自行扩展的view标签有哪些。接受单个值，也可以用`逗号`作为分隔符从而接受字符串数组
2. `idref_attrs` 开发者自定义的view可能需要引用其他view的ID来达到特殊的布局效果，而编译器在编译过程中会对ID做自动转化。为了让开发者自定义的ID引用属性能够加入这个过程中，可以通过此配置项声明对应属性的名字
3. `actions` 开发者告知编译器哪些是自定义的action节点，这样编译器结合内置和传入的自定义标签就可以清晰的分辨action、view和callback三种类型的数据了
