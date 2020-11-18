## 接口设计

SDK对外提供的重要API的详细描述

### 初始化与配置

设计
```
DBRuntime.register(accessKey, wrapper_impl)
```
用以初始化DB的Runtime，并注册对应accessKey
- `accessKey` accessKey
- `wrapper_impl` 可空，业务方自己的接入层实现。若某功能接入方为实现则返回空，内部通过simple-wrapper进行兜底（需集成）

```
DBRuntime.setConfig(accessKey, config)
```
用以更新DBRuntime的配置信息
- `accessKey` accessKey
- `config` 配置选项，如配置是否打开数据监控
    + `report` 是否开启SDK内部运行数据上报，接入方可以用于统计错误信息，收集使用数据用于优化页面性能
    + `sampleFrequency` 设置内部数据上报频率，可设置 0%~100%，默认值为 10%

具体API：
#### Android

````java
void register(@NonNull String accessKey, @NonNull Application application, @Nullable WrapperImpl impl);

void setConfig(@NonNull String accessKey, @Nullable DreamBoxConfig config)
````

示例
````java
DreamBox.getInstance().register("key", application, wrapperImpl);

DreamBox.getInstance().setConfig("key", config);
````

#### iOS

````objc
- (void)registerAccessKey:(NSString *)accessKey wrapper:(DBWrapper *)wrapper;
- (void)setConfig:(DBWrapperConfigModel *)config accessKey:(NSString *)accessKey;

````
示例

````objc
[[DBService shareDBService] registerAccessKey:@"key" wrapper:wrapper];
[[DBService shareDBService] setConfig:cofig accessKey:key];
````

### 渲染

设计
```
DBView.render(accessKey, template_id, ext_data, callback)
```
- `accessKey` 同上
- `template_id` 必传，表示一个模板在其accessKey维度下的唯一ID（Runtime不做检查，依赖接入方自行保障唯一性）。此ID的功能有：
  - 索引随版发布的内置DB模板数据，文件名规则为`local.{template_id}.dbt`(DreamBox Template)，开发者可选是否内置。若内置，则当此ID无法索引到其他模板数据时，将以内置为兜底数据。若无内置，又无法索引到其他数据，则DBView的渲染行为落空
  - DB的整体闭环逻辑中认为始终存在着一个发布系统，这个发布系统的职责是通过`template_id`和`app_version`唯一定位到一条渲染模板数据
  >综合扩展性和可用性考量，DB内部并没有集成发布系统相关的具体逻辑，而是将这部分的顶层能力透传给外部做具体实现，详情见[发布方案建议](publish_recommand.md)
- `ext_data` 可空（建议必传）,对应[数据设计](../design/data.md)中所描述的透传数据，在DSL中可直接体现为`ext`关键字
- `callback`：异步回调，返回值布尔。若为`真值`代表此DBView成功渲染，此时若有被遮罩的NativeView，则此NativeView应该设置为不可见（为优化性能）；若为`假值`则代表此DBView渲染出错或落空

#### 模板数据优先级

模板数据来源：
1. 本地：`local.{template_id}.dbt`
2. 发布系统：由接入方传入的`template_id`和`app_version`唯一定位

##### 优先级

发布系统获取到的渲染数据优先级高于本地，本地的渲染数据作为兜底，若兜底落空，则对应DBView渲染行为落空


具体API：
#### Android

````java
void render(@NonNull String accessKey, @NonNull String templateId, @Nullable OnRenderCallback callback);

void render(@NonNull String accessKey, @NonNull String templateId, @Nullable String extJsonStr, @Nullable OnRenderCallback callback);

void render(@NonNull String accessKey, @NonNull String templateId, @Nullable  String extJsonStr, @Nullable OnRenderCallback callback, @NonNull Lifecycle lifecycle);

void setExtJsonStr(@NonNull final String extJsonStr);
````

+ `lifecycle`  *(Lifecycle)*：获取所属页面生命周期，默认使用 `fragmentActivity.getLifecycle()`
+ `callback` *(OnRenderCallback)*：渲染结果，回调结构如下

````java
public interface OnRenderCallback {
    void onRender(boolean success);
}
````

示例
````java
DreamBoxView dmbView = findViewById(R.id.dream_box);
dmbView.render("dmb-demo", "hello", ext, callback);
...
// 更新外部数据
dreamView.setExtJsonStr(extNew);
````

本地模板

存放在应用 assets 目录下

比如：模板为 `hello` ，命名为 `local.hello.dbt` 文件即可，文件内容为 cli 编译出的最终数据

#### iOS
````objc
- (void)loadWithTemplateId:(NSString *)tid accessKey:(NSString *)accessKey extData:(NSDictionary *)ext completionBlock:(DBTreeRenderBlock)completionBlock;
- (void)bindExtensionMetaData:(NSDictionary *)ext;
````
示例

````objc
[DBTreeview loadWithTemplateId:tid accessKey:@"DEMO" extData:ext completionBlock:^(BOOL successed, NSError * _Nullable error) {
        
}];
[DBTreeview bindExtensionMetaData:data];
````
### 数据池

```
DBRuntime.putPoolData(accessKey, data_key, data_value)
```
- `accessKey` 同上
- `data_key` 数据在池中体现的key，在DSL中可获取：`pool.data_key`
- `data_value` 数据的具体值

具体API：

#### Android

````java
void putPoolData(@NonNull String accessKey, @NonNull String dataKey, @NonNull String dataValue);
````

示例
````java
DreamBox.getInstance().putPoolData("accessKey", "dataKey", "dataValue");
````

#### iOS

````objc
- (void)putPoolDataByAccessKey:(NSString *)accessKey dataKey:(NSString *)dataKey dataValue:(NSString *)dataValue;

````
示例

````objc
[[DBService shareDBService] putPoolDataByAccessKey:@"AccessKey" dataKey:@"key" dataValue:@"value"];

````