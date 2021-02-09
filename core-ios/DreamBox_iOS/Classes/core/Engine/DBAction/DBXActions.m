//
//  DBActions.m
//  DreamBox_iOS
//
//  Created by didi on 2020/7/16.
//

#import "DBXActions.h"
#import "DBXWrapperManager.h"
#import "DBXParser.h"
#import "DBXPool.h"
#import "NSDictionary+DBXExtends.h"
#import "DBXValidJudge.h"
#import "DBXTreeView.h"

@implementation DBXActions

#pragma mark -
// 如果 value 是 keypath 则从 metaDict/公共pool/ext 取出
// 如果 value 就是 value 设置进入 paraDict
+ (void)paraDict:(NSMutableDictionary *)paraDict originDict:(NSDictionary *)originDict checkKey:(NSString *)key pathId:(NSString *)pathId {
    NSString *temKey = [originDict objectForKey:key];
    NSString *realValue = [DBXParser getRealValueByPathId:pathId andKey:temKey];
    [paraDict db_setValue:realValue forKey:key];
}

-(void)actWithDict:(NSDictionary *)dict andPathId:(NSString *)pathId frame:(CGRect)frame{
    //none
}

@end


@implementation DBXLogAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *logDict = [DBXLogAction parseLogWithDict:originDict andPathId:pathId];
    [[DBXWrapperManager sharedManager] logService:logDict accessKey:accessKey];
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

@implementation DBXNetAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
#if DEBUG
//    NSString *key = [originDict objectForKey:@"to"];
//    NSArray *students = @[@{
//        @"img": @"https://dss1.bdstatic.com/6OF1bjeh1BF3odCf/it/u=2007348240,921224949&fm=74&app=80&f=JPEG&size=f121,90?sec=1880279984&t=b35e463135347add61aca95427a4dc75",
//        @"name": @"小zhang1",
//        @"age": @"16"
//    }];
//
//
//    [[DBXPool shareDBPool] setObject:@{key:students} ToDBMetaPoolWithPathId:pathId];

//    NSString *key = [originDict objectForKey:@"to"];
//    [[DBXPool shareDBPool] setObject:@{key:@"https://ss1.bdstatic.com/"} ToDBMetaPoolWithPathId:pathId];
#endif
    
    NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *netDict = [DBXNetAction parseNetWithDict:originDict andPathId:pathId];
    
    NSDictionary *onErrorDict;
    NSDictionary *onSuccessDict;
    
    NSArray *callBacks = [originDict db_objectForKey:@"callbacks"];
    for(NSDictionary *dict in callBacks){
        NSString *type = [dict db_objectForKey:@"_type"];
        if([type isEqual:@"onSuccess"]){
            onSuccessDict = dict;
        }
        if([type isEqual:@"onError"]){
            onErrorDict = dict;
        }
    }
    
    [[DBXWrapperManager sharedManager] netService:netDict accessKey:accessKey successBlock:^(id  _Nonnull data) {
    if ([originDict db_hasKey:@"to"]) {
        NSString *key = [originDict objectForKey:@"to"];
        if ([DBXValidJudge isValidString:key] && data) {
            NSDictionary *addDict = [NSDictionary dictionaryWithObjectsAndKeys:data,key, nil];
            [[DBXPool shareDBPool] setObject:addDict ToDBMetaPoolWithPathId:pathId];
            }
        }
        [DBXParser  circulationActionDict:onSuccessDict andPathId:pathId];
    } failureBlock:^(NSError * _Nonnull error) {
        [DBXParser  circulationActionDict:onErrorDict andPathId:pathId];
    }];
}

+ (NSDictionary *)parseNetWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId {
    NSString *urlKey = @"url";
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    [self paraDict:paraDict originDict:originDict checkKey:urlKey pathId:pathId];
    return paraDict;
}


@end

@implementation DBXTraceAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *traceDict = [DBXTraceAction parseTraceWithDict:originDict andPathId:pathId];
    [[DBXWrapperManager sharedManager] traceService:traceDict accessKey:accessKey];
}

+ (NSDictionary *)parseTraceWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId {
    NSString *traceKey = @"key";
    NSString *attrKey = @"attr";
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    [self paraDict:paraDict originDict:originDict checkKey:traceKey pathId:pathId];
    NSArray *attr = [originDict objectForKey:attrKey];
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    if ([DBXValidJudge isValidArray:attr]){
        // 解析 trace
       for (NSDictionary *dict in attr) {
           if ([DBXValidJudge isValidDictionary:dict]){
               NSString *key = [dict objectForKey:@"key"];
               NSString *value = [dict objectForKey:@"value"];
               if ([DBXValidJudge isValidString:key] && [DBXValidJudge isValidString:value]) {
                   NSString *realValue = [DBXParser getRealValueByPathId:pathId andKey:value];
                   [attrDict db_setValue:realValue forKey:key];
               }
           }
       }
    } else if ( [DBXValidJudge isValidDictionary:(NSDictionary *)attr] ) {
        NSDictionary *dict = (NSDictionary *)attr;
        NSString *key = [dict objectForKey:@"key"];
        NSString *value = [dict objectForKey:@"value"];
        if ([DBXValidJudge isValidString:key] && [DBXValidJudge isValidString:value]) {
            
            NSString *realValue = [DBXParser getRealValueByPathId:pathId andKey:value];
            [attrDict db_setValue:realValue forKey:key];
        }
    }
    [paraDict db_setValue:attrDict forKey:attrKey];
    return paraDict;
}
    
@end

@implementation DBXNavAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *onErrorDict = [originDict objectForKey:@"onError"];
    NSDictionary *onSuccessDict = [originDict objectForKey:@"onSuccess"];
    NSDictionary *schemaDict = [DBXNavAction parseNavWithDict:originDict andPathId:pathId];
    [[DBXWrapperManager sharedManager] navService:schemaDict accessKey:accessKey  successBlock:^{
        [DBXParser  circulationActionDict:onSuccessDict andPathId:pathId];
    } failureBlock:^{
        [DBXParser  circulationActionDict:onErrorDict andPathId:pathId];
    }];
}

+ (NSDictionary *)parseNavWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId {

    NSString *schmeaKey = @"schema";
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    
    [self paraDict:paraDict originDict:originDict checkKey:schmeaKey pathId:pathId];
    return paraDict;
}

@end

@implementation DBXStorageAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *storageDict = [DBXStorageAction parseStorageWithDict:originDict andPathId:pathId];
    [[DBXWrapperManager sharedManager] storageService:storageDict accessKey:accessKey callback:^(NSDictionary * _Nonnull dict) {
        [[DBXPool shareDBPool] setObject:dict ToDBMetaPoolWithPathId:pathId];
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

@implementation DBXDialogAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *dialogDict = [DBXDialogAction parseDialogWithDict:originDict andPathId:pathId];
    NSDictionary *onErrorDict = [originDict objectForKey:@"onError"];
    NSDictionary *onSuccessDict = [originDict objectForKey:@"onSuccess"];
    [[DBXWrapperManager sharedManager] dialogService:dialogDict accessKey:accessKey positiveBlock:^{
        [DBXParser  circulationActionDict:onSuccessDict andPathId:pathId];
    } negativeBlock:^{
        [DBXParser  circulationActionDict:onErrorDict andPathId:pathId];
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

@implementation DBXToastAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    NSDictionary *toastDict = [DBXToastAction parseToastWithDict:originDict andPathId:pathId];
    [[DBXWrapperManager sharedManager] toastService:toastDict accessKey:accessKey];
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

@implementation DBXChangeMetaAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    if ([originDict db_hasKey:@"key"] && [originDict db_hasKey:@"value"]) {
        NSString *key = [originDict db_stringForKey:@"key" defaultValue:@""];
        NSString *value = [originDict db_stringForKey:@"value" defaultValue:@""];
        if ([DBXValidJudge isValidString:key] && [DBXValidJudge isValidString:value]) {
            NSDictionary *addDict = [NSDictionary dictionaryWithObjectsAndKeys:value,key, nil];
            [[DBXPool shareDBPool] setObject:addDict ToDBMetaPoolWithPathId:pathId];
        }
    }
}

@end

@implementation DBXInvokeAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    NSString *finkey = [originDict objectForKey:@"alias"];
    
    NSDictionary *paramDict;
    //一、获取参数
    id src = [originDict objectForKey:@"src"];
    if([src isKindOfClass:[NSString class]]){
        paramDict = [DBXParser getRealValueByPathId:pathId andKey:src];
    }
    
    if([src isKindOfClass: [NSDictionary class]]){
        paramDict = (NSDictionary *)src;
    }
    [[DBXPool shareDBPool] setObject:paramDict ToDBMetaPoolWithPathId:pathId];

    //二、获取alias
    id aliasObj = [[DBXPool shareDBPool] getObjectFromAliasPoolWithPathId:pathId];
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
        [DBXParser circulationActionDict:targetAlias andPathId:pathId];
    }else {
        [DBXInvokeAction trace_action_alias_not_found:finkey andPathId:pathId];
    }
}

+(void)trace_action_alias_not_found:(NSString *)alias_id andPathId:(NSString *)pathId
{
    //包含未知alias_id,数据统计trace_action_alias_not_found开始
    NSString *accessKey  = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    [[DBXWrapperManager sharedManager] reportTid:pathId Key:@"tech_trace_action_alias_not_found" accessKey:accessKey params:@{@"alias_id":@""} frequency:DBReportFrequencyEVERY];
    //数据统计trace_action_alias_not_found结束
}



@end

@implementation DBXClosePageAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
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

@implementation DBXSendEventAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    NSString *eventId = [originDict db_objectForKey:@"eid"];
    if(originDict && eventId.length > 0){
        DBXTreeView *treeView = [[DBXPool shareDBPool] getDBViewWithPathId:pathId];
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

@implementation DBXOnEventAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)pathId frame:(CGRect)frame{
    [[DBXPool shareDBPool] setObject:originDict ToDBOnEventDictWithPathId:pathId];
}

@end

