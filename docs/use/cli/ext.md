## 扩展支持

CLI支持接入方通过命令行中`--extcfg`参数后传入`yaml`格式配置文件的方式，让编译器支持编译接入方自行扩展的UI或动作标签

### 配置文件编写方式

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
