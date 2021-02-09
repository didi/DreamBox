//
//  DBXParser.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXParser.h"
#import <objc/runtime.h>
#import "DBXViewModel.h"
#import "DBXView.h"
#import "DBXImage.h"
#import "DBXProgress.h"
#import "UIColor+DBXColor.h"
#import "UIView+DBXStrike.h"
#import "DBXService.h"
#import <SDWebImage/SDWebImage.h>
#import "DBXHelper.h"
#import "DBXFactory.h"
#import "DBXViewProtocol.h"
#import "DBXActionProtocol.h"
#import "DBXWrapperManager.h"
#import "DBXActions.h"
#import "Masonry.h"
#import "DBXCallBack.h"
#import "NSArray+DBXExtends.h"
#import "DBXFlexBoxLayout.h"

#import "DBXViewModel.h"
#import "DBXYogaModel.h"

@implementation DBXParser

+(DBXTreeModel *)parserDict:(NSDictionary *)dict
{
    NSDictionary *dictAll = [dict objectForKey:@"dbl"];
    DBXTreeModelYoga *treeModel = [DBXTreeModelYoga modelWithDict:dictAll];

    return treeModel;
}



+(NSMutableDictionary *)recursiveParseOriginDict:(NSDictionary *)originDict withMap:(NSDictionary *)mapDict
{
    if (!originDict || !mapDict) {
        return nil;
    }
    NSArray *arrOriginKey = [originDict allKeys];
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    
    for (NSString *key in arrOriginKey) {
        
        if (key && [mapDict objectForKey:key]) {
            
            id Value = [originDict objectForKey:key];
            if ([Value isKindOfClass:NSDictionary.class]) {
                // 字典处理
                NSDictionary *tmpValue = [DBXParser recursiveParseOriginDict:Value withMap:mapDict];
                NSString *tmpKey = [mapDict objectForKey:key];
                [newDic db_setValue:tmpValue forKey:tmpKey];
                
            } else if ([Value isKindOfClass:NSArray.class]) {
                // 数组处理
                NSMutableArray *tmpArray = [NSMutableArray array];
                for (NSDictionary *dic in Value) {
                    if ([dic isKindOfClass:NSDictionary.class]) {
                        NSDictionary* tmpValue = [DBXParser recursiveParseOriginDict:dic withMap:mapDict];
                        [tmpArray db_addObject:tmpValue];
                    }
                }
                NSString *newKey = [mapDict objectForKey:key];
                [newDic db_setValue:tmpArray forKey:newKey];
            } else {
                
                NSString *newKey = [mapDict objectForKey:key];
                [newDic db_setValue:Value forKey:newKey];
            }

        }else{
            // 无需处理，没有map对应的
            newDic = [NSMutableDictionary dictionaryWithDictionary:originDict];
        }
    }
    originDict = newDic;
    return newDic;
}

+(NSDictionary *)parseOriginDict:(NSDictionary *)originDict withMap:(NSDictionary *)mapDict
{
    if (!originDict || !mapDict) {
        return nil;
    }
    NSMutableDictionary *retMapDict = [DBXParser recursiveParseOriginDict:originDict withMap:mapDict];
    NSDictionary *retDict = [NSDictionary dictionaryWithObjectsAndKeys:retMapDict,@"dbl", nil];
    return retDict;
}

//模型到DBView
+ (DBXBaseView *)modelToView:(DBXViewModel *)model andPathId:(NSString *)pathId
{

    Class cls = [[DBXFactory sharedInstance] getViewClassByType:model._type];
    if (!cls) {
        [self trace_node_unknown:model._type andPathId:pathId];
    }
    
    //lifeCycle：创建视图
    DBXBaseView *view = [[cls alloc] initWithFrame:CGRectZero];
    view.pathId = pathId;
    
    if ([(NSObject<DBXViewProtocol> *)view respondsToSelector:@selector(onCreateView)]) {
        [(NSObject<DBXViewProtocol> *)view onCreateView];
    }
    
    if ([(NSObject<DBXViewProtocol> *)view respondsToSelector:@selector(setDataWithModel:andPathId:)]) {
        [(NSObject<DBXViewProtocol> *)view setDataWithModel:model andPathId:pathId];
    }
    
    //lifeCycle：绑定数据
    if ([(NSObject<DBXViewProtocol> *)view respondsToSelector:@selector(onAttributesBind:)]) {
        [(NSObject<DBXViewProtocol> *)view onAttributesBind:model];
    }
    
    //lifeCycle：对于集合视图，进行子视图处理
    if([(NSObject<DBXViewProtocol> *)view respondsToSelector:@selector(onChildrenBind:model:)]
       && (model.children.count > 0)) {
        [(NSObject<DBXViewProtocol> *)view onChildrenBind:view model:model];
    }
    
    if(model.backgroundColor){
        view.backgroundColor =  [UIColor db_colorWithHexString:model.backgroundColor];
    }
    
    view.modelID = model.modelID;
    
    //控制是否能打开用户交互
    if([model.userInteractionEnabled isEqual:@"0"]){
        view.userInteractionEnabled = NO;
    } else {
        view.userInteractionEnabled = YES;
    }
    
    //处理回调
    view.callBacks = model.callbacks;
    [[DBXCallBack shareInstance] bindView:view withCallBacks:view.callBacks pathId:view.pathId];

    return view;
}

+ (NSString *)paserStr:(NSString *)str
{
    NSString *str1 = [str
    stringByReplacingOccurrencesOfString:@"${" withString:@""];
    NSString *str2 = [str1
           stringByReplacingOccurrencesOfString:@"}" withString:@""];
    return str2;
}

//遍历action节点执行
+ (void)circulationActionDict:(NSDictionary *)actionDict andPathId:(NSString *)pathId
{
    NSArray *arr = [actionDict objectForKey:@"actions"];
    if(arr.count > 0){
        [arr enumerateObjectsUsingBlock:^(NSDictionary *action, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *arr = [action allKeys];
            for (NSInteger i = 0; i < arr.count; i++) {
                NSString *key = arr[i];
                NSDictionary *originDict = [action objectForKey:key];
                NSValue *frame = [actionDict db_objectForKey:@"frame"];
                if ([DBXParser isHandleDependOn:originDict andPathId:pathId]) { return;}  //如果有dependOn依赖
                Class cls = [[DBXFactory sharedInstance] getActionClassByType:key];
                DBXActions *act = [[cls alloc] init];
                if ([(NSObject<DBXActionProtocol> *)act respondsToSelector:@selector(actWithDict:andPathId:frame:)]) {
                    [(NSObject<DBXActionProtocol> *)act actWithDict:originDict andPathId:pathId frame:[frame CGRectValue]];
                }
            }
        }];
    }
}

+(BOOL)isHandleDependOn:(NSDictionary *)originDict andPathId:(NSString *)pathId
{
    //如果有依赖查看依赖再执行,否则立即执行
    if (![originDict isKindOfClass:[NSDictionary class]]) {
        return true;
    }
    NSString *dependOnStr = [originDict objectForKey:@"dependOn"];
    if ([DBXValidJudge isValidString:dependOnStr] && [self isMetaKey:dependOnStr]) {
        NSString *metakey = [DBXParser paserStr:dependOnStr];
        NSDictionary *metaDict = [[DBXPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId];
        NSString *key = [metaDict objectForKey:metakey];
        if ([DBXValidJudge isValidString:key] && ![key isEqualToString:@"true"]) {
            return true;
        }
    }
    return false;
}


#pragma mark -
+ (BOOL)isMetaKey:(NSString *)key {
    if (![DBXValidJudge isValidString:key] ) {
        return NO;
    }
    
    if ([key hasPrefix:@"${"] && [key hasSuffix:@"}"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEXTKey:(NSString *)key {
    
    if (![DBXValidJudge isValidString:key] ) {
        return NO;
    }
    
    if ([key containsString:@"ext."]) {
        return YES;
    }
    
    return NO;
}


+ (BOOL)isGlobalPoolKey:(NSString *)key {
    
    if (![DBXValidJudge isValidString:key] ) {
        return NO;
    }
    BOOL isPrefix = [key hasPrefix:@"${gp"] || [key hasPrefix:@"${GP"];
    if ( isPrefix && [key hasSuffix:@"}"]) {
        return YES;
    }
    return NO;
}

+ (id)getRealValueByPathId:(NSString *)pathId andKey:(NSString *)key{

    if(!key){
        return nil;
    }
    
    NSMutableString *finalValue = [[NSMutableString alloc] initWithString:key];

    //字符串操作较密集，增加try-catch防崩
    @try {
        //正则匹配出${X}字符
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\$)\\S*?(\\})"  options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matchs = [regex matchesInString:key options:0 range:NSMakeRange(0, [key length])];
        //顺序用真实值替换掉${X}
        if(matchs.count > 0){
            for(NSTextCheckingResult *result in matchs){
                NSRange range = result.range;
                NSString *originKey = [key substringWithRange:range];
                NSString *realValue = [self getRealValueByPathId:pathId andOriginKey:originKey];
                if([realValue isKindOfClass:[NSString class]]){
                    finalValue = [finalValue stringByReplacingOccurrencesOfString:originKey withString:realValue].mutableCopy;
                } else{
                    return realValue;
                }
            }
        }
        return finalValue;
    } @catch (NSException *exception) {
#if DEBUG
        NSAssert(NO, @"解析src数据异常，请排查相关json");
#endif
        return finalValue;
    }
}


+ (id)getRealValueByPathId:(NSString *)pathId andOriginKey:(NSString *)key{
    if (![DBXValidJudge isValidString:key]) {
        return @"";
    }
    
    if ([DBXParser isGlobalPoolKey:key]) {
        
        if ([key containsString:@"gp."]) {
             key = [key stringByReplacingOccurrencesOfString:@"gp." withString:@""];
         } else if ([key containsString:@"GP."]) {
             key = [key stringByReplacingOccurrencesOfString:@"GP." withString:@""];
         }
        
        NSString *paserKey = [DBXParser paserStr:key];
        if ([[DBXPool shareDBPool] getObjectFromDBGlobalPoolWithPathId:pathId]) {
            NSDictionary *GlobalPool = [[DBXPool shareDBPool] getObjectFromDBGlobalPoolWithPathId:pathId];
            return [GlobalPool objectForKey:paserKey];
        }
    } else if ([DBXParser isMetaKey:key]) {
        NSString *paserKey = [DBXParser paserStr:key];
        if ([[DBXPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId] != nil || [[DBXPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId] != nil) {
            if ([DBXParser isEXTKey:paserKey]) {
                NSDictionary *ext = [[DBXPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId];
                NSString *extkey = [paserKey stringByReplacingOccurrencesOfString:@"ext." withString:@""];
                return [self getObjectFromExtDict:ext key:extkey];
            }else{
                NSDictionary *meta = [[DBXPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId];
                return [self getObjectFromExtDict:meta key:paserKey];
            }
        }
        
    } else {
        return key;
    }
    
    return key;
}

+(id)getObjectFromExtDict:(NSDictionary *)extDict key:(NSString *)key{
    NSMutableString *vKey = [key mutableCopy];
    NSMutableDictionary *vDict = [extDict mutableCopy];
    
    while ([vKey containsString:@"["]) {
        NSRange rangeL = [vKey rangeOfString:@"["];
        NSRange rangeR = [vKey rangeOfString:@"]"];
        if(rangeR.location - rangeL.location > 0){
            NSString *idxStr = [vKey substringWithRange:NSMakeRange(rangeL.location + 1, rangeR.location - rangeL.location - 1)];
            NSString *arrKey = [vKey substringToIndex:rangeL.location];
            NSArray *subArr = [vDict db_valueForPathId:arrKey];
            NSInteger idx = idxStr.integerValue;
            vDict = [subArr db_ObjectAtIndex:idx];
            if(rangeR.location + rangeR.length >= vKey.length){
                return vDict;
            }
            vKey = [[vKey substringFromIndex:rangeR.location + 2] mutableCopy];
        } else{
            break;
        }
    }
    NSObject *result = [vDict db_valueForPathId:vKey];
    return result;
}

+ (id)getMetaDictByPathId:(NSString *)pathId {
    if (![DBXValidJudge isValidString:pathId]) {
        return nil;
    }
    return [[DBXPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId];
}





+ (BOOL)isvalidAction:(NSString *)action {
    NSArray *dbValidActions = @[@"log",@"net",@"trace",@"nav",@"storage",@"dialog",@"toast",@"changeMeta",@"invoke",@"closePage",@"sendEvent",@"onEvent"];
    if([dbValidActions containsObject:action]){
        return YES;
    }
    return NO;;
}

#pragma 数据统计

+(void)trace_node_unknown:(NSString *)type andPathId:(NSString *)pathId
{
    //包含未知节点,数据统计trace_node_unknown开始
    NSString *accessKey  = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    [[DBXWrapperManager sharedManager] reportTid:pathId Key:@"tech_trace_node_unknown" accessKey:accessKey params:@{@"parent_node":@"",@"node_name":type?type:@""} frequency:DBReportFrequencyEVERY];
    //数据统计trace_node_unknown结束
}

+(void)trace_attr_unknown:(NSString *)type andPathId:(NSString *)pathId
{
    //包含未知节点,数据统计trace_node_unknown开始
    NSString *accessKey  = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    [[DBXWrapperManager sharedManager] reportTid:pathId Key:@"tech_trace_attr_unknown" accessKey:accessKey params:@{@"attr_name":@"",@"node_name":type} frequency:DBReportFrequencyEVERY];
    //数据统计trace_node_unknown结束
}

+(void)trace_action_alias_not_found:(NSString *)alias_id andPathId:(NSString *)pathId
{
    //包含未知alias_id,数据统计trace_action_alias_not_found开始
    NSString *accessKey  = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
    [[DBXWrapperManager sharedManager] reportTid:pathId Key:@"tech_trace_action_alias_not_found" accessKey:accessKey params:@{@"alias_id":@""} frequency:DBReportFrequencyEVERY];
    //数据统计trace_action_alias_not_found结束
}


@end
