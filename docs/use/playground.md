## Playground


### 一、下载&集成

#### iOS ：

````
https://github.com/didi/DreamBox/playground-ios
pod install
````
运行结果

![](../assets/ios-playground2.png ':size=25%')


#### Android ：

扫码下载：

![](../assets/playgroundv3.png ':size=30%')


### 二、使用
#### Step1 启动长链接服务

1. 前提条件：环境准备就绪 详见[环境准备](environment.md)、[CLI使用说明](cli.md)
2. 将以下代码保存为demo.xml文件
    ```xml
<dbl xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <meta hello_text="Hello DreamBox!" right_btn_visible="false" img_src="https://images.unsplash.com/photo-1593642531955-b62e17bdaa9c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80" />
    <layout type="yoga" height="fill" width="fill" >
        <text id="tv1" src="${hello_text}"/>
        <text id="tv2" src="ToBottom of Hello text" marginTop="33dp"/>
        <text src="Center Text" positionType="absolute" positionTop="50%" marginBottom="10dp" />
        <image src="${img_src}" positionType="absolute" positionLeft="0dp" positionBottom="0dp" width="150dp" height="150dp"/>
    </layout>
</dbl>
    ```
3. 启动长链接服务
    ```
    dmb-cli demo.xml
    ```
输出示例

    ![](../assets/ios-playground1.png ':size=60%')

#### Step2 绑定长链接服务

方式1：打开本地调试信息发布地址链接，获得二维码

![](../assets/ios-playground4.png ':size=80%')

扫码；

![](../assets/ios-playground5.png ':size=30%')![](../assets/ios-playground6.png ':size=30%')

方式2：直接拷贝webSocket服务地址，输入，绑定；

![](../assets/ios-playground3.png ':size=30%')![](../assets/ios-playground6.png ':size=30%')