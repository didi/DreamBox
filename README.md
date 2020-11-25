
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
## 简介
<img src="https://didi.github.io/DreamBox/assets/ic_dreambox.jpg" width="150">
<br>
这是一个为客户端打造的、具有动态化功能、性能优秀的统一视图开发框架——`One DSL, Both run`

## 产生背景

身为客户端开发同学的你，是否遇到过以下问题：
1. 要开发一个运营位，按钮一会想在上边，一会想在下边，预埋？可以cover住所有情况吗？
2. 已有的一些信息卡片，内容中的标签想挪到上边去，开发量不大，10分钟就调完的东西却不得不通过发版解决
3. 紧急的需求来了，要在首页上展示一个新型样式的运营活动，除了借用Webview有更好的办法吗？千万量级用户的背景下，真的所有人的内存都撑得住吗？

`DreamBox`就是用来解决以上问题的，它本身是一个视图容器，容器内部的内容可以通过线上下发的方式任意动态化更新。而且并不集成运行时虚拟机，最大程度贴近原生开发，没有中间商吃内存、耗性能。

## 目标
`DreamBox`立志于能在双端的原生视图框架和运行时之上搭建一个统一的、具备动态化能力、可以灵活扩展的视图开发框架，同时保持优秀的运行时性能，并不断建设组件和落地生态，降低50%的客户端视图开发工作量，让开发人员腾出双手做更多更有意义的事情。


## 基本原理
`DreamBox`的发起和发展都离不开“前辈”们的点醒。我们深入调研了像RN、Weex、Flutter、Tangram等优秀框架，结合所处的业务环境特点和自身的核心诉求，选择了广泛吸取前辈经验和优点，自立门户。
<br>
“前辈”们基本上都是能独当一面的全能型选手，甚至具有独立开发整个App的能力。当然，这受益于Javascript、Dart及其运行时。实际开发中，这带来了两个问题：
1. 是否大家都能够良好掌握JS或Dart语言
2. 针对一些简单的卡片乃至页面，这些大型框架显然可以应对，但随之而来的内存和性能损耗，有杀鸡用牛刀的架势

当然，这里再额外提一句，`Flutter`官方并未提供动态更新功能。

基于以上，我们认为：复杂的场景上我们可以充分利用已有框架的能力，支持复杂场景、复杂交互，随之而来的开发成本和内存等消耗是值得的。但在简单场景中，比如一些没有复杂交互需求，只是进行信息展示的需求，能以更快速、更轻便的方案进行支撑。
<br>
我们希望：一方面能不能通过简单的语言学习甚至于基于已有的就可以进行双端开发；另一方面，内存和性能的额外消耗是否可以压至最低，无限接近原生。所以，`DreamBox`最终选择了：
1. 仿照Android约束布局进行DSL的初版定义，后期结合实际情况分支发展。这样一来，大大降低Android开发者的学习门槛。另外，有限的DSL规则和属性远比学习一门真正的语言来的更快，iOS开发同学的掌握速度也较快
2. 不集成语言运行时，进行静态解析。通过这种方式，让DB的运行时生命周期足够短暂，避免依附View存活而带来的持续的内存消耗问题。另一方面，因为没有语言运行时，动态解析的性能损耗大大降低

粗粒度上，`DreamBox`通过以下几个步骤完成了整体功能：
1. 开发者编写DSL
2. 编译器编译DSL为DB Runtime可以接受的数据格式
3. DB Runtime解析数据并映射为原生数据、绑定交互事件
4. 原生运行时进行渲染并传递交互事件
5. DB Runtime响应交互事件做动作

简而言之，`DreamBox`定义了一套统一的DSL，在Android和iOS的原生视图框架和运行时的基础上，搭建了另一个运行时。这个运行时生命周期短、内存损耗小，将这一套DSL分别映射成两个系统能够接受的数据，完成了展现一致、体验一致的视图页面。


## 功能特性
> 先通过一个Gif简单认识下

![demo gif](https://didi.github.io/DreamBox/assets/db-demo.gif)

`DreamBox`将一个视图中的各种元素分为三类：
1. 视图元素，这类元素就是直接展示在用户眼前的View。这类元素可以动态化改变其内部属性和外部布局
2. 交互、回调元素，视图的点击、长按等交互事件或动作发生后的回调统称为这类元素。它们是视图背后交互逻辑的触发点
3. 动作元素，如网络请求、日志、弹窗、打电话等等这些隐藏在视觉背后的、由交互、回调元素触发的归为此类

比如：一个卡片的组成是图片+按钮，当按钮点击时，跳转另一个页面。这句话中，图片、按钮以及他们的布局关系就是`视觉元素`，按钮的点击就是`交互、回调元素`，最后的跳转就是`动作元素`。

`DreamBox`所支持的功能特性有：
1. 支持视图元素的复杂约束关系布局，每一个元素可以在横纵坐标轴上相对于其他元素进行标记定位，相比`flex`这能支持一些更复杂的场景需求
2. 不仅仅是视图元素，支持对以上三个元素都进行动态修改
3. 支持三方进行DSL扩展，以适应更加复杂、更加具体的需求场景
4. 支持通过`Event API`与原生运行时进行双工通信，满足一些DB框架无法满足的功能需求
5. 支持通过`Playground`或`debug-tool`的集成达成实时调试预览的效果
6. 支持单个App中多个引擎实例集成，互不干扰
7. 支持复杂的数据使用场景，包含内置固定、二次请求以及原生透传
8. 内置10余个视图组件，包含列表和流式布局
9. 内置10余个动作功能，部分基础功能接入方可以自行接管具体实现
10. 细粒度低至View，可在页面中自由嵌入使用

详细功能请参见[开发手册](https://didi.github.io/DreamBox/)

### 在路上 
1. 扩展框架优化，方便开发者在两个平台上能更加快速的扩展新View以及Action
2. 类链式布局支持，实际开发场景中迫切需要此类功能以达到整体居中等诉求
3. 扩展更多内置组件，以及对一些内置组件支持更多的功能、属性
4. 在数据属性中支持简单的语义解析
5. 支持原生Runtime从DB Runtime中获取已经渲染好的View实例
6. 动画支持

更多实用功能，欢迎你来[提出](https://github.com/didi/DreamBox/issues)

## 项目成员

**发起人**
- [Kevin Liu](https://github.com/lkv1988)

**内部开发者**
- [Kevin Liu](https://github.com/lkv1988)
- [syxchenjing](https://github.com/sxychenjing)
- [zhch19910514](https://github.com/zhch19910514)
- [Shaosheng Fang](https://github.com/fss1994)
- [HQNSummer](https://github.com/HQNSummer)
- [KSKjust](https://github.com/KSKjust)
- [music-man(民)](https://github.com/music-man)

**外部贡献者**
> 等你加入

## 社区共建
`DreamBox`已经在滴滴顺风车的业务开发中落地支持了若干需求。我们在持续对框架进行新功能开发以及性能优化，希望能支持更多的场景。相对于远景目标，需要做的事情还有很多。

- 如果你对本项目有兴趣，请不要吝惜你的`star⭐️`
- 如果你想参与到项目的开发中来，欢迎向我们发起Pull Request
- 任何问题（使用、原理、BUG等）欢迎向我们提交、与我们讨论，[Issue](https://github.com/didi/DreamBox/issues)和QQ群都是不错的沟通方式
- 如果你的App采用了`DreamBox`，请让我们知道

> QQ群

<img src="https://didi.github.io/DreamBox/assets/db_qq_qrcode.png" width="220">

## License

```
Copyright 2020 DiDi

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
