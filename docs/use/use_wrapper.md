## Wrapper接入

### 设计
DreamBox将SDK内部使用的各种基础能力（如网络、日志、埋点等）抽象得抽离为了`wrapper`层。`wrapper`层作为`engine`层的底部支撑。

通过抽象接口化及实现可插拔的设计，接入方可以有挑选的对`wrapper`所提供的能力进行实现并替换，以使得`DreamBox`能够更好的融入你的工程业务中。

### 能力接口

#### log

##### Android
````java
public interface Log {
    void v(@NonNull String msg);

    void d(@NonNull String msg);

    void i(@NonNull String msg);

    void w(@NonNull String msg);

    void e(@NonNull String msg);
}
````

##### iOS
````objc
+ (void)log:(DBLogLevel)level tag:(NSString *)tag msg:(NSString *)msg;
````

#### net

##### Android
````java
public interface Net {
    interface Callback {
        void onSuccess(@Nullable String json);

        void onError(int httpCode, @Nullable Exception error);
    }

    void get(@NonNull String url, @Nullable Callback cb);
}
````

##### iOS
````objc
+ (void)request:(NSString *)urlStr successBlock:(DBNetSuccessBlock)successBlock failureBlock:(DBNetFailureBlock)failureBlock;
````

#### trace

##### Android
````java
public interface Trace {
    void t(@NonNull String key,@Nullable Map<String, String> attrs);
}
````

##### iOS
````objc
+ (void)trace:(NSString *)key value:(NSDictionary *)value;
````

#### nav

##### Android
````java
public interface Navigator {
    void navigator(@NonNull Context context, @NonNull String url);
}
````

##### iOS
````objc
+ (void)navigatorBySchema:(NSString *)schema;
````

#### storage

##### Android
````java
public interface Storage {
    void put(@NonNull String key, @NonNull String value);

    String get(@NonNull String key, @NonNull String defaultValue);
}

````

##### iOS
````objc
+ (void)setStorage:(NSString *)value forkey:(NSString *)key;
+ (NSString *)getStorageBykey:(NSString *)key;
````

#### dialog

##### Android
````java
public interface Dialog {
    interface OnClickListener {
        void onClick();
    }

    void show(@NonNull Context context, @Nullable String title, @Nullable String msg,
              @Nullable String positiveBtn, @Nullable String negativeBtn,
              @Nullable OnClickListener posListener,
              @Nullable OnClickListener negListener);
}
````

##### iOS
````objc
+ (void)showAlertViewWithTitle:(nullable NSString *)title
                       message:(nullable NSString *)message
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle
              otherButtonTitle:(nullable NSString *)otherButtonTitle
             cancelButtonBlock:(nullable DBAlertClickBlock)cancelBlock
              otherButtonBlock:(nullable DBAlertClickBlock)otherBlock;
````

#### toast

##### Android
````java
public interface Toast {
    void show(@NonNull Context context, @NonNull String msg, boolean durationLong);
}
````

##### iOS
````objc
+ (void)showToast:(NSString *)str longTime:(BOOL)longTime; 
````

#### template

##### Android
````java
public interface Template {

    interface Callback {
        void onLoadTemplate(@Nullable String template);
    }

    @WorkerThread
    void loadTemplate(@NonNull String templateId, @NonNull Callback callback);
}
````

#### iOS
````objc
-(void)getDataByTemplateId:(NSString *)tid completionBlock:(void(^)(NSError * _Nullable error,NSString *_Nullable data))completionBlock;
````


#### imageLoader

##### Android
````java
public interface ImageLoader {
    void load(@NonNull String url, @NonNull ImageView imageView);
}
````

##### iOS
````objc
+ (void)imageView:(UIImageView *)imgView setImageUrl:(NSString *)urlStr;
````

#### monitor

##### Android
````java
public interface Monitor {
    void report(@NonNull String type, @Nullable Map<String, String> params);
}
````

##### iOS
````objc
+ (void)reportKey:(NSString *)key params:(NSDictionary<NSString * ,NSString *>*)params;
````

### 默认实现

#### 依赖默认实现库

Android : 内部对能力已经做了默认实现

因为 *wrapper* 中包含图片、网络的实现，如果要使用这些能力，还需要补齐依赖
````
    implementation "com.android.volley:volley:1.1.1"
    implementation("com.github.bumptech.glide:glide:4.11.0") {
        exclude group: "com.android.support"
    }
````
如果希望接入指定的网络、图片库，请参考 `自定义替换` 进行替换。

iOS : 默认实现为 `DBDefaultWrapper` , 内部有各个基本节点的基础实现，如需自定义替换请参考 `自定义替换`

### 自定义替换

#### 实现

##### Android
自定义wrapper需要继承 `WrapperImpl` 并覆写需要实现的对应功能方法。

如果不实现某功能接口，或返回值为null，则会 使用 *simple-wrapper* 作为功能实现；若也未引用 *simple-wrapper*，则该功能无法使用，为空实现。


##### iOS
自定义wrapper需要继承 `DBWrapper` 并实现 `DBWrapperProtocl` 的方法，未实现方法则会走默认实现

#### 注册

DreamBox 内部使用注册机制，来保证多个业务单元可以自定义自己的wrapper实现，也意味着需要注册和区分机制。我们引入了accessKey的概念，每个业务单元使用自己的accessKey来注册自己的wrapper。

##### Android
````java
void register(@NonNull String accessKey, @NonNull Application application, @Nullable WrapperImpl impl);
````

示例
````java
DreamBox.getInstance().register("yourKey", application, wrapperImpl);
````

##### iOS
````
- (void)registerAccessKey:(NSString *)accessKey wrapper:(DBWrapper *)wrapper;
````
示例
````
[[DBService shareDBService] registerAccessKey:@"yourKey" wrapper:yourWrapper];
````