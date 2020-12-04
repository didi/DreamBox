## `<pack>`

Added in v0.3

### 设计
版本 | 描述
---|---
v0.3 | 虚拟容器，用于包裹其他view对象，实现对多个对象的整体布局。虚拟容器本身是不可见的，只是用来辅助布局一组UI元素。

![pack示意图](../../assets/pack_01.png ':size=50%')

### 属性

#### Added in v0.3
支持基本属性里的位置属性和边距属性，以上图整体居中为例，[完整示例](https://didi.github.io/DreamBox/assets/pack_demo_01.xml)：
```
<dbl>
    <render>
        ......
        <pack
            bottomToBottom="bg_border"
            id="pack_test"
            leftToLeft="bg_border"
            rightToRight="bg_border"
            topToTop="bg_border">
            <text
                backgroundColor="#69CD9E"
                color="#FFFFFF"
                id="txt_1"
                leftToLeft="pack_test"
                rightToLeft="txt_2"
                src="组件 1" />
            <text
                backgroundColor="#69CD9E"
                color="#FFFFFF"
                id="txt_2"
                leftToRight="txt_1"
                marginLeft="5dp"
                rightToLeft="txt_3"
                src="组件 2" />
            <text
                backgroundColor="#69CD9E"
                color="#FFFFFF"
                id="txt_3"
                leftToRight="txt_2"
                marginLeft="5dp"
                rightToRight="pack_test"
                src="组件 3" />
        </pack>
    </render>
</dbl>
```



### 交互响应

无特殊
