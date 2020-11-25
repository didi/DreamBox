## 编译器产物数据结构

前边简单介绍过编译器的基本原理，会对模板数据加一些版本及校验数据，最终做BASE64产出编译产物。其中最重要的是DSL（XML）所转化而成的Json数据，这部分数据是DSL和SDK连接的协议纽带。这部分会介绍最新的Json结构，一方面最为内部开发的数据协议标准。另一方面编译有兴趣的开发者进行了解。

### 数据转化

#### 转化过程中的类型解释
编译器在v0.3中，在DSL的遍历过程里赋予了每一个抽象节点类型的概念，目前有以下几个类型：
- `DummyNode`，只有虚拟的root节点是此类型
- `ViewNode`，所有的View节点都会是此类型，编译器根据内置的节点以及用户传入的ext.yaml中`ext`->`views`进行识别。此类型节点的特点是：
  - ID会进行自动转化
  - 只有此类型节点可拥有`children`子节点
  - `pack`也是此节点
- `PackNode`，只有`pack`节点是此类型。之所以特殊对待，是因为此节点不能拥有`callbacks`子节点，除此之外和`ViewNode`没有区别。添加此类型方便在转换后做数据结构校验
- `ActionNode`，和View一样，编译器凭借内置的动作标签列表和用户传入的yaml中的actions扩展进行识别，此节点可以拥有属性和`callback`，但不可能拥有`children`
- `CallbackNode`，所有非View、非Action但又以`on`开头的节点会被自动识别为此类型，这个节点只可能拥有Action类型的子节点，也只能被Action或View包含。不存在Callback的嵌套行为
- `AttrNode`属性节点。此类型没有实际用途，只是用来做属性的类型标记

#### 转化规则

- 首先，json会拥有`dbl`根节点，内容是obj。为了理解，此节点可以认为是一个特殊的视图节点，因为其可拥有`callbacks`节点。但特殊的如`meta`|`actionAlias`|`render`这些节点其实并不是视图节点的内容，他们只能被根节点包含
- `meta`节点中存储着DSL中转化而来的元数据部分内容。这部分内容基本上就是原封不动的转化，在ID替换、混淆过程中，这个区域都是白名单区域，不会涉及。因为这里是开发者期待的数据，其内容不可修改。这里是支持内部的嵌套结构的。`meta`本身是个obj，内部可以嵌套其他的obj，只要在使用时开发者可以对应的引用即可
- 动作类型节点转化后的规则比较简单，其拥有自己的属性，有的可能拥有callback回调。动作节点都会被收敛在`actions`节点下。可以肯定的是，`actions`节点只可能被回调节点拥有。因为在设计上，回调节点是任何事件的触发点。每一个动作节点是一个json-obj，所以即使存在多个同样类型的动作，也不会在`actions`节点下产生混乱，其触发顺序就是开发者在DSL中书写的顺序，同样最终也是转化Json时的动作
- `render`是一个渲染模板中最为重要的节点，其包含了所有的视图及其对应的回调和动作。但其结构比较简单，这一定是一个json-array，它的一级子节点都只能是view类型
- 考虑到view在原生运行时中是需要Z轴的概念的，所以必须要保障解析view后的顺序和DSL中的顺序是一致的。每一个view是一个json-obj，其内部通过一个`type`表示这个view是什么类型的。view拥有最全量的数据结构，一方面是自己的各种属性，另一方面`callbacks`|`children`都可以被这个节点拥有。当然，如果DSL中没有给这个view设置回调事件，这个view本身也不是容器属性的话，这两个节点都不会有了
- `children`的结构和`render`是一样的，也是简单的。是数组，里边只能是view
- `callbacks`节点是一个json-array类型，其内容是回调数据。每一个回调数据通过`type`表明自己是什么回调，比如`onClick`。回调数据就这么简单明了的表明了自己，同时再结合包含的`actions`字段，就能清晰的描述了此回调发生时将会触发什么事件。一个不包含任何有效的action的回调节点实际上是无效的

#### 附加节点

- `ids`，上边提到过，所有view里边的ID会进行自动转化，所谓转化是将DSL中的字符串ID转换为自增的整型ID。这一个字段就存储了这个自动的转化映射表，之所以存储这个数据是为了在运行时，SDK可以有能力提供给开发者用DSL中的ID找到实际的View实例的功能
- `map`，混淆一是为了最终线上应用的模板数据不要直接明文，二是为了能够在产出阶段进行一定量的压缩。涵盖的范围是`meta`节点外的数据

### 编译器的愿景想法

待数据结构和转化规则经过迭代平稳后，直接编译成二进制码，最大化传输效率和解析速度。

#### 示例

```json
{
 "dbl": {
  "meta": {
   "showTitle": "true",
   "traceOnVisible": "true",
   "list": {
    "name": "value"
   }
  },
  "callbacks": [
   {
    "type": "onVisible",
    "actions": [
     {
      "trace": {
       "key": "trace_on_visible",
       "attr": [
        {
         "key": "key_1",
         "value": "value_11111"
        },
        {
         "key": "key_2",
         "value": "value_2"
        },
        {
         "key": "key_3",
         "value": "value3_333"
        }
       ]
      }
     },
     {
      "log": {
       "src": "456"
      }
     },
     {
      "toast": {
       "src": "123"
      }
     },
     {
      "toast": {
       "src": "111"
      }
     }
    ]
   }
  ],
  "render": [
   {
    "id": "1",
    "src": " Title",
    "height": "40dp",
    "type": "text"
   },
   {
    "id": "2",
    "src": "asdklajsdlkjasdlkda Title",
    "topToBottom": "1",
    "type": "text"
   },
   {
    "id": "3",
    "src": "Button below the title ",
    "topToBottom": "2",
    "type": "button",
    "callbacks": [
     {
      "type": "onClick",
      "actions": [
       {
        "log": {
         "msg": "while button clicked, log this one",
         "tag": "view_log",
         "level": "i"
        }
       }
      ]
     }
    ]
   },
   {
    "topToBottom": "3",
    "src": "Bottom Button",
    "type": "button",
    "callbacks": [
     {
      "type": "onClick",
      "actions": [
       {
        "toast": {
         "src": "\u5c55\u793a\u4e00\u4e2aToast"
        }
       },
       {
        "invoke": {
         "alias": "3"
        }
       },
       {
        "dialog": {
         "callbacks": [
          {
           "type": "onNegative"
          },
          {
           "type": "onPositive"
          }
         ]
        }
       }
      ]
     }
    ]
   },
   {
    "id": "4",
    "width": "fill",
    "height": "300dp",
    "type": "list",
    "children": [
     {
      "parentId": "list_1",
      "type": "header",
      "children": [
       {
        "src": "im a header",
        "type": "text"
       }
      ]
     },
     {
      "type": "vh",
      "children": [
       {
        "src": "a list cell",
        "type": "text"
       }
      ]
     },
     {
      "type": "footer",
      "children": [
       {
        "src": "im a footer",
        "type": "text"
       }
      ]
     }
    ]
   },
   {
    "id": "5",
    "src": "123",
    "width": "fill",
    "type": "flow",
    "children": [
     {
      "type": "cell",
      "children": [
       {
        "id": "6",
        "srcId": "detail_card_title",
        "src": "a flow cell child-view",
        "type": "text"
       },
       {
        "src": "another flow cell child-view",
        "type": "text"
       }
      ]
     }
    ]
   },
   {
    "topToTop": "0",
    "bottomToBottom": "0",
    "marginTop": "20",
    "marginBottom": "50",
    "id": "7",
    "type": "pack",
    "children": [
     {
      "id": "8",
      "marginTop": "5",
      "bottomToTop": "9",
      "topToTop": "7",
      "type": "view"
     },
     {
      "id": "9",
      "marginTop": "5",
      "topToBottom": "8",
      "bottomToBottom": "7",
      "type": "view"
     }
    ]
   }
  ],
  "actionAlias": [
   {
    "id": "3",
    "actions": [
     {
      "toast": {
       "src": "123"
      }
     },
     {
      "log": {
       "src": "456"
      }
     }
    ]
   },
   {
    "id": "4",
    "actions": [
     {
      "toast": {
       "src": "123"
      }
     },
     {
      "log": {
       "src": "456"
      }
     }
    ]
   }
  ]
 },
 "ids": {
  "parent": "0",
  "tv_1": "1",
  "tv_2": "2",
  "btn_1": "3",
  "list_1": "4",
  "flow_1": "5",
  "tv333": "6",
  "123": "7",
  "1231": "8",
  "1232": "9"
 }
}
```