## 命令行工具使用说明

### 安装

详见[环境准备](../environment.md)

如果要安装开发中的最新版CLI可以在[testpypi](https://test.pypi.org/project/dmb-cli/)中找到。

> PS：开发版中的CLI经常用于内部调试开发使用，有新功能的同时也常伴随着其他问题，不保证完全可用，请谨慎安装

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
- 会发布本地的`http server`告知相关调试信息（包含编译码及中间态的Json码）
- 会发布本地`websocket server`，并将二维码发布在上一项提供的html中，开发者可以通过`Playground`App或`debug-tool`的调试入口扫码绑定手机上的DBView
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

#### 配置文件编写方式

示例：
```yaml
ext:
  view_tags: list, vh, header, footer, flow
  view_parent_tags: list, vh, header, footer, flow
  idref_attr_names: parentId
  callback_tags: onCancel

```

#### ext
考虑到配置文件将来可能承载扩展功能之外的配置参数，所以`ext`视为扩展相关参数的开始标签，必须存在

内部参数说明：
1. `view_tags` 告知编译器自行扩展的view标签有哪些。接受单个值，也可以用`逗号`作为分隔符从而接受字符串数组
2. `view_parent_tags` 告知编译器自行扩展的view标签中哪个（些）是作为**view容器**般（view parent）的存在，这样的节点会在编译过程中自动添加`children`节点，在`children`节点下存放其子view集合（以下数据格式只代表v2阶段编译器的编译格式，不保证将来依旧生效，读者应只做理解参考）：
```json
{
    "children": [
     {
      "src": "a flow cell child-view",
      "type": "text"
     },
     {
      "src": "another flow cell child-view",
      "type": "text"
     }
    ],
    "type": "flow"
}
```
3. `idref_attr_names` 开发者自定义的view可能需要引用其他view的ID来达到特殊的布局效果，而编译器在编译过程中会对ID做自动转化。为了让开发者自定义的ID引用属性能够加入这个过程中，可以通过此配置项声明对应属性的名字
4. `callback_tags` 告知编译器开发者自定扩展的节点中哪个（些）是回调节点（关于节点的抽象分类，请[参考](../../dsl/write_a_dsl.md))，因为编译器会在编译过程中对收集到的某个callback下的action节点做特殊整理，所以对于自定义的callback需要让编译器知道。这样，在最终的终端RUNTIME中才能成功匹配扩展框架的数据结构，开发者方可顺利接管其处理逻辑


#### 关于3.X版本

- 3.X版本由于编译转化数据结构变化较大，故不再提供向下兼容老版本（v1、v2），编出来的版本最低只能支持v3版本的DB SDK
- 对于ext配置文件的支持依然采用`--extcfg`的参数传入方式，但配置文件的内容编写规则产生了一定变化

##### yaml配置文件变化

根据[编译器产物数据结构](../../spec/cli_out_format.md)中的描述，现在CLI只需要认识View和Action即可，Callback类型会通过节点命名进行自动推断。而ID属性依然还是需要感知的，所以CLI在3.X后配置文件的内容更新为：
1. 父节点`ext`不变，表示扩展内容
2. `view_tags`节点命名改为`views`，原因：简短
3. 新增`actions`字段，内容格式和`views`一样，都是以逗号间隔的数组。代表开发者自定义的Action节点
4. `idref_attr_names`改名为`idref_attrs`，原因：简短
5. 其他未提到的节点删除

示例：
如`ext.yaml`的内容如下：
```yaml
ext:
    views:customViewA,customViewB
    idref_attrs:idrefA, idrefB
    actions:customActA, customActB
```

```
dmb-cli --extcfg ext.yaml my_db_dsl.xml
```
这样一来，编译器就认识你自定义的这些属性了，可以编译出期待的转化后数据