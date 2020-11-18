//
//  DBActions.m
//  DreamBox_iOS
//
//  Created by didi on 2020/7/16.
//

#import "DBActions.h"
#import "DBWrapperManager.h"
#import "DBParser.h"
#import "DBPool.h"
#import "NSDictionary+DBExtends.h"
#import "DBValidJudge.h"
#import "DBWrapperManager.h"
#import "DBTreeView.h"

@implementation DBActions

#pragma mark -
// 如果 value 是 keypath 则从 metaDict/公共pool/ext 取出
// 如果 value 就是 value 设置进入 paraDict
+ (void)paraDict:(NSMutableDictionary *)paraDict originDict:(NSDictionary *)originDict checkKey:(NSString *)key pathId:(NSString *)pathId {
    NSString *temKey = [originDict objectForKey:key];
    NSString *realValue = [DBParser getRealValueByPathId:pathId andKey:temKey];
    [paraDict db_setValue:realValue forKey:key];
}

@end


@implementation DBLogAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    NSString *accessKey = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *logDict = [DBLogAction parseLogWithDict:originDict andPathId:pathId];
    [[DBWrapperManager sharedManager] logService:logDict accessKey:accessKey];
}

+ (NSDictionary *)parseLogWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId {

    NSString *levelKey = @"level";
    NSString *tagKey = @"tag";
    NSString *msgKey = @"msg";
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    
    [self paraDict:paraDict originDict:originDict checkKey:levelKey pathId:pathId];
    [self paraDict:paraDict originDict:originDict checkKey:tagKey pathId:pathId];
    [self paraDict:paraDict originDict:originDict checkKey:msgKey pathId:pathId];
    return paraDict;
}

@end

@implementation DBNetAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
#if DEBUG
//    NSString *key = [originDict objectForKey:@"to"];
//    NSArray *students = @[@{
//        @"img": @"https://dss1.bdstatic.com/6OF1bjeh1BF3odCf/it/u=2007348240,921224949&fm=74&app=80&f=JPEG&size=f121,90?sec=1880279984&t=b35e463135347add61aca95427a4dc75",
//        @"name": @"小zhang1",
//        @"age": @"16"
//    }];
//
//
//    [[DBPool shareDBPool] setObject:@{key:students} ToDBMetaPoolWithPathId:pathId];

//    NSString *key = [originDict objectForKey:@"to"];
//    [[DBPool shareDBPool] setObject:@{key:@"https://ss1.bdstatic.com/"} ToDBMetaPoolWithPathId:pathId];
#endif
    
    NSString *accessKey = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *netDict = [DBNetAction parseNetWithDict:originDict andPathId:pathId];
    NSDictionary *onErrorDict = [originDict objectForKey:@"onError"];
    NSDictionary *onSuccessDict = [originDict objectForKey:@"onSuccess"];
    [[DBWrapperManager sharedManager] netService:netDict accessKey:accessKey successBlock:^(id  _Nonnull data) {
    if ([originDict db_hasKey:@"to"]) {
        NSString *key = [originDict objectForKey:@"to"];
        if ([DBValidJudge isValidString:key] && data) {
            NSDictionary *addDict = [NSDictionary dictionaryWithObjectsAndKeys:data,key, nil];
            [[DBPool shareDBPool] setObject:addDict ToDBMetaPoolWithPathId:pathId];
            }
        }
        [DBParser  circulationActionDict:onSuccessDict andPathId:pathId];
    } failureBlock:^(NSError * _Nonnull error) {
        [DBParser  circulationActionDict:onErrorDict andPathId:pathId];
    }];
}

+ (NSDictionary *)parseNetWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId {
    NSString *urlKey = @"url";
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    [self paraDict:paraDict originDict:originDict checkKey:urlKey pathId:pathId];
    return paraDict;
}


@end

@implementation DBTraceAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    NSString *accessKey = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *traceDict = [DBTraceAction parseTraceWithDict:originDict andPathId:pathId];
    [[DBWrapperManager sharedManager] traceService:traceDict accessKey:accessKey];
}

+ (NSDictionary *)parseTraceWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId {
    NSString *traceKey = @"key";
    NSString *attrKey = @"attr";
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    [self paraDict:paraDict originDict:originDict checkKey:traceKey pathId:pathId];
    NSArray *attr = [originDict objectForKey:attrKey];
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    if ([DBValidJudge isValidArray:attr]){
        // 解析 trace
       for (NSDictionary *dict in attr) {
           if ([DBValidJudge isValidDictionary:dict]){
               NSString *key = [dict objectForKey:@"key"];
               NSString *value = [dict objectForKey:@"value"];
               if ([DBValidJudge isValidString:key] && [DBValidJudge isValidString:value]) {
                   NSString *realValue = [DBParser getRealValueByPathId:pathId andKey:value];
                   [attrDict db_setValue:realValue forKey:key];
               }
           }
       }
    } else if ( [DBValidJudge isValidDictionary:attr] ) {
        NSDictionary *dict = (NSDictionary *)attr;
        NSString *key = [dict objectForKey:@"key"];
        NSString *value = [dict objectForKey:@"value"];
        if ([DBValidJudge isValidString:key] && [DBValidJudge isValidString:value]) {
            
            NSString *realValue = [DBParser getRealValueByPathId:pathId andKey:value];
            [attrDict db_setValue:realValue forKey:key];
        }
    }
    [paraDict db_setValue:attrDict forKey:attrKey];
    return paraDict;
}
    
@end

@implementation DBNavAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    NSString *accessKey = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *onErrorDict = [originDict objectForKey:@"onError"];
    NSDictionary *onSuccessDict = [originDict objectForKey:@"onSuccess"];
    NSDictionary *schemaDict = [DBNavAction parseNavWithDict:originDict andPathId:pathId];
    [[DBWrapperManager sharedManager] navService:schemaDict accessKey:accessKey  successBlock:^{
        [DBParser  circulationActionDict:onSuccessDict andPathId:pathId];
    } failureBlock:^{
        [DBParser  circulationActionDict:onErrorDict andPathId:pathId];
    }];
}

+ (NSDictionary *)parseNavWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId {

    NSString *schmeaKey = @"schema";
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    
    [self paraDict:paraDict originDict:originDict checkKey:schmeaKey pathId:pathId];
    return paraDict;
}

@end

@implementation DBStorageAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    NSString *accessKey = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *storageDict = [DBStorageAction parseStorageWithDict:originDict andPathId:pathId];
    [[DBWrapperManager sharedManager] storageService:storageDict accessKey:accessKey callback:^(NSDictionary * _Nonnull dict) {
        [[DBPool shareDBPool] setObject:dict ToDBMetaPoolWithPathId:pathId];
    }];
}

+ (NSDictionary *)parseStorageWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId{

    NSString *storageKey = @"key";
    NSString *writeKey = @"write";
    NSString *readKey = @"readTo";
    
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    
    [self paraDict:paraDict originDict:originDict checkKey:storageKey pathId:pathId];
    [self paraDict:paraDict originDict:originDict checkKey:writeKey pathId:pathId];
    [self paraDict:paraDict originDict:originDict checkKey:readKey pathId:pathId];

    return paraDict;
}
@end

@implementation DBDialogAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    NSString *accessKey = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *dialogDict = [DBDialogAction parseDialogWithDict:originDict andPathId:pathId];
    NSDictionary *onErrorDict = [originDict objectForKey:@"onError"];
    NSDictionary *onSuccessDict = [originDict objectForKey:@"onSuccess"];
    [[DBWrapperManager sharedManager] dialogService:dialogDict accessKey:accessKey positiveBlock:^{
        [DBParser  circulationActionDict:onSuccessDict andPathId:pathId];
    } negativeBlock:^{
        [DBParser  circulationActionDict:onErrorDict andPathId:pathId];
    }];
}


+ (NSDictionary *)parseDialogWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId{

    NSString *titleKey = @"title";
    NSString *msgKey = @"msg";
    NSString *positiveBtnKey = @"positiveBtn";
    NSString *negativeBtnKey = @"negativeBtn";
    
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    [self paraDict:paraDict originDict:originDict checkKey:titleKey pathId:pathId];
    [self paraDict:paraDict originDict:originDict checkKey:msgKey pathId:pathId];
    [self paraDict:paraDict originDict:originDict checkKey:positiveBtnKey pathId:pathId];
    [self paraDict:paraDict originDict:originDict checkKey:negativeBtnKey pathId:pathId];

    return paraDict;
}
@end

@implementation DBToastAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    NSString *accessKey = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *toastDict = [DBToastAction parseToastWithDict:originDict andPathId:pathId];
    [[DBWrapperManager sharedManager] toastService:toastDict accessKey:accessKey];
}


#pragma mark - Toast
+ (NSDictionary *)parseToastWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId{
    
    NSString *srcKey = @"src";
    NSString *longKey = @"long";
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    
    [self paraDict:paraDict originDict:originDict checkKey:srcKey pathId:pathId];
    [self paraDict:paraDict originDict:originDict checkKey:longKey pathId:pathId];
    return paraDict;
}


@end

@implementation DBChangeMetaAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    if ([originDict db_hasKey:@"key"] && [originDict db_hasKey:@"value"]) {
        NSString *key = [originDict db_stringForKey:@"key" defaultValue:@""];
        NSString *value = [originDict db_stringForKey:@"value" defaultValue:@""];
        if ([DBValidJudge isValidString:key] && [DBValidJudge isValidString:value]) {
            NSDictionary *addDict = [NSDictionary dictionaryWithObjectsAndKeys:value,key, nil];
            [[DBPool shareDBPool] setObject:addDict ToDBMetaPoolWithPathId:pathId];
        }
    }
}

@end

@implementation DBInvokeAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    NSString *finkey = [originDict objectForKey:@"alias"];
    
    NSDictionary *paramDict;
    //一、获取参数
    id src = [originDict objectForKey:@"src"];
    if([src isKindOfClass:[NSString class]]){
        paramDict = [DBParser getRealValueByPathId:pathId andKey:src];
    }
    
    if([src isKindOfClass: [NSDictionary class]]){
        paramDict = (NSDictionary *)src;
    }
    [[DBPool shareDBPool] setObject:paramDict ToDBMetaPoolWithPathId:pathId];

    //二、获取alias
    id aliasObj = [[DBPool shareDBPool] getObjectFromAliasPoolWithPathId:pathId];
    __block NSDictionary *targetAlias;
    if([aliasObj isKindOfClass:[NSArray class]]){
        NSArray *aliasArr = (NSArray *)aliasObj;
        [aliasArr enumerateObjectsUsingBlock:^(NSDictionary *aliasDict, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *aliasId = [aliasDict objectForKey:@"id"];
            if([finkey isEqualToString:aliasId]){
                targetAlias = aliasDict;
                *stop = YES;
            }
        }];
    } else {
        targetAlias = (NSDictionary *)aliasObj;
    }
    //二、执行alias
    if(targetAlias){
//        NSArray *target []
        [DBParser circulationActionDict:targetAlias andPathId:pathId];
    }else {
        [DBInvokeAction trace_action_alias_not_found:finkey andPathId:pathId];
    }
}

+(void)trace_action_alias_not_found:(NSString *)alias_id andPathId:(NSString *)pathId
{
    //包含未知alias_id,数据统计trace_action_alias_not_found开始
    NSString *accessKey  = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    [[DBWrapperManager sharedManager] reportTid:pathId Key:@"tech_trace_action_alias_not_found" accessKey:accessKey params:@{@"alias_id":@""} frequency:DBReportFrequencyEVERY];
    //数据统计trace_action_alias_not_found结束
}



@end

@implementation DBClosePageAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    id vc = [self currentNC];
    if([vc isKindOfClass: [UINavigationController class]]) {
        [(UINavigationController *)vc popViewControllerAnimated:YES];
    } else if ([vc isKindOfClass: [UIViewController class]]) {
        [(UIViewController *)vc dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UINavigationController *)currentNC
{
    if (![[UIApplication sharedApplication].windows.lastObject isKindOfClass:[UIWindow class]]) {
        NSAssert(0, @"未获取到导航控制器");
        return nil;
    }
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self getCurrentNCFrom:rootViewController];
}

- (id)getCurrentNCFrom:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UINavigationController *nc = ((UITabBarController *)vc).selectedViewController;
        return [self getCurrentNCFrom:nc];
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        if (((UINavigationController *)vc).presentedViewController) {
            return [self getCurrentNCFrom:((UINavigationController *)vc).presentedViewController];
        }
        return [self getCurrentNCFrom:((UINavigationController *)vc).topViewController];
    }
    else if ([vc isKindOfClass:[UIViewController class]]) {
        if (vc.presentedViewController) {
            return [self getCurrentNCFrom:vc.presentedViewController];
        }
        else {
            if(vc.navigationController){
                return vc.navigationController;
            } else {
                return vc;
            }
            
        }
    }
    else {
        NSAssert(0, @"未获取到导航控制器");
        return nil;
    }
}

@end

@implementation DBSendEventAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    NSString *eventId = [originDict db_objectForKey:@"eid"];
    if(originDict && eventId.length > 0){
        DBTreeView *treeView = [[DBPool shareDBPool] getDBViewWithPathId:pathId];
        DBTreeEventBlock blk = [treeView eventBlockWithEventId:[originDict db_objectForKey:@"eid"]];
        NSDictionary *msg = [originDict db_objectForKey:@"msg"];
        NSDictionary *callBack = [originDict db_objectForKey:@"callback"];
        NSMutableDictionary *callBackData =  [[NSMutableDictionary alloc] init];
        [callBackData addEntriesFromDictionary:callBack];
        if(blk){
            blk(eventId ,msg, callBackData);
        }
    }
}

@end

@implementation DBOnEventAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId{
    [[DBPool shareDBPool] setObject:originDict ToDBOnEventDictWithPathId:pathId];
}

@end

