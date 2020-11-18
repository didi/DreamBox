//
//  DBParser.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBParser.h"
#import <objc/runtime.h>
#import "DBViewModel.h"
#import "DBView.h"
#import "DBText.h"
#import "DBImage.h"
#import "DBProgress.h"
#import "UIColor+DBColor.h"
#import "UIView+DBStrike.h"
#import "DBService.h"
#import <SDWebImage/SDWebImage.h>
#import "DBHelper.h"
#import "DBFactory.h"
#import "DBViewProtocol.h"
#import "DBActionProtocol.h"
#import "DBWrapperManager.h"
#import "DBActions.h"
#import "Masonry.h"
#import "DBCallBack.h"

@implementation DBParser

+(DBTreeModel *)parserDict:(NSDictionary *)dict
{
    NSDictionary *dictAll = [dict objectForKey:@"dbl"];
    DBTreeModel *treeModel2 = [[DBTreeModel alloc] init];
    treeModel2.displayType = [dictAll db_objectForKey:@"displayType"];
    treeModel2.width = [dictAll db_objectForKey:@"width"];
    treeModel2.height = [dictAll db_objectForKey:@"height"];
    treeModel2.dismissOn = [dictAll db_objectForKey:@"dismissOn"];
    treeModel2.onVisible = [dictAll db_objectForKey:@"onVisible"];
    treeModel2.onInvisible = [dictAll db_objectForKey:@"onInvisible"];
    treeModel2.meta = [dictAll db_objectForKey:@"meta"];
    treeModel2.render = [dictAll db_objectForKey:@"render"];
    treeModel2.actionAlias = [dictAll db_objectForKey:@"actionAlias"];
    treeModel2.onEvent = [dictAll db_objectForKey:@"onEvent"];
    treeModel2.scroll = [dictAll db_objectForKey:@"scroll"];
    treeModel2.isSubTree = [dict db_objectForKey:@"isSubTree"];
    treeModel2.callbacks = [dictAll db_objectForKey:@"callbacks"];
    return treeModel2;
    
}



+(NSDictionary *)recursiveParseOriginDict:(NSDictionary *)originDict withMap:(NSDictionary *)mapDict
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
                NSDictionary *tmpValue = [DBParser recursiveParseOriginDict:Value withMap:mapDict];
                NSString *tmpKey = [mapDict objectForKey:key];
                [newDic db_setValue:tmpValue forKey:tmpKey];
                
            } else if ([Value isKindOfClass:NSArray.class]) {
                // 数组处理
                NSMutableArray *tmpArray = [NSMutableArray array];
                for (NSDictionary *dic in Value) {
                    if ([dic isKindOfClass:NSDictionary.class]) {
                        NSDictionary* tmpValue = [DBParser recursiveParseOriginDict:dic withMap:mapDict];
                        [tmpArray addObject:tmpValue];
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
    NSMutableDictionary *retMapDict = [DBParser recursiveParseOriginDict:originDict withMap:mapDict];
    NSDictionary *retDict = [NSDictionary dictionaryWithObjectsAndKeys:retMapDict,@"dbl", nil];
    return retDict;
}

//模型到DBView
+ (DBView *)modelToView:(DBViewModel *)model andPathId:(NSString *)pathId
{

    Class cls = [[DBFactory sharedInstance] getViewClassByType:model.type];
    if (!cls) {
        [self trace_node_unknown:model.type andPathId:pathId];
    }
    
    //lifeCycle：创建视图
    DBBaseView *view = [[cls alloc] initWithFrame:CGRectZero];
    view.pathId = pathId;
    
    if ([(NSObject<DBViewProtocol> *)view respondsToSelector:@selector(setDataWithModel:andPathId:)]) {
        [(NSObject<DBViewProtocol> *)view setDataWithModel:model andPathId:pathId];
    }
    
    //lifeCycle：绑定数据
    if ([(NSObject<DBViewProtocol> *)view respondsToSelector:@selector(onAttributesBind:)]) {
        [(NSObject<DBViewProtocol> *)view onAttributesBind:model];
    }
    
    //lifeCycle：对于集合视图，进行子视图处理
    if([(NSObject<DBViewProtocol> *)view respondsToSelector:@selector(onChildrenBind:model:)]
       && (model.children.count > 0)) {
        [(NSObject<DBViewProtocol> *)view onChildrenBind:view model:model];
    }
    
    
    view.backgroundColor =  [UIColor db_colorWithHexString:model.backgroundColor];
    view.modelID = model.modelID;
    
    //控制是否隐藏
    if (model.visibleOn) {
        if ([[self getRealValueByPathId:pathId andKey:model.visibleOn] isEqualToString:@"false"]) {
            view.hidden = YES;
        }else{
            view.hidden = NO;
        }
    }
    
    //控制是否能打开用户交互
    if([model.userInteractionEnabled isEqual:@"0"]){
        view.userInteractionEnabled = NO;
    } else {
        view.userInteractionEnabled = YES;
    }
    
    //处理回调
    view.callBacks = model.callbacks;
    [DBCallBack bindView:view withCallBacks:view.callBacks];

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

//layout布局
+ (void)layoutAllViews:(DBViewModel *)model andView:(DBView *)view andRelativeViewPool:(DBRecyclePool *)pool
{
    //处理children的布局
    //宽
    if ([model.width floatValue] != 0) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([DBDefines db_getUnit:model.width]).priority(MASLayoutPriorityRequired);
        }];
    }
    
    //高
    if ([model.height floatValue] != 0) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([DBDefines db_getUnit:model.height]).priority(MASLayoutPriorityRequired);
        }];
    }
    
    //宽填满
    if ([model.width isEqualToString:@"fill"]) {
        UIView *relationView = [pool getItemWithIdentifier:@"0"];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(relationView.mas_width).priority(MASLayoutPriorityRequired);
        }];
    }
    
    //高填满
    if ([model.height isEqualToString:@"fill"]) {
        UIView *relationView = [pool getItemWithIdentifier:@"0"];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(relationView.mas_height).priority(MASLayoutPriorityRequired);
        }];
    }
    
    
    if ([model.width isEqualToString:@"wrap"]) {
        if([view isKindOfClass:[DBText class]]){
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo([view wrapSize]);
            }];
        } else {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo([view wrapSize].width);
            }];
        }
    }
    
    
    if ([model.height isEqualToString:@"wrap"]) {
        if([view isKindOfClass:[DBText class]]){
            //如果text，给定宽度，自适应高，则让系统计算，放弃手算
        } else {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo([view wrapSize].height);
            }];
        }
    }
    
    if((model.leftToLeft || model.leftToRight)
       && (model.rightToRight || model.rightToLeft)
       &&  !model.marginLeft && !model.marginRight){

        UIView *tmpV = [UIView new];
        [view.superview addSubview:tmpV];
        
        UIView *leftRelationView;
        if(model.leftToRight){
            leftRelationView = [pool getItemWithIdentifier:model.leftToRight];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(leftRelationView.mas_right);
            }];
        } else {
            leftRelationView = [pool getItemWithIdentifier:model.leftToLeft];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(leftRelationView.mas_left);
            }];
        }
        
        UIView *rightRelationView;
        if(model.rightToLeft){
            rightRelationView = [pool getItemWithIdentifier:model.rightToLeft];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightRelationView.mas_left);
            }];
        } else {
            rightRelationView = [pool getItemWithIdentifier:model.rightToRight];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightRelationView.mas_right);
            }];
        }
        
        if (model.width != nil && [DBDefines db_getUnit:model.width] == 0) {
            //写死0的case下，自适应
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(tmpV);
                make.right.mas_equalTo(tmpV);
            }];
        }else{
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(tmpV);
            }];
        }
    } else{
        if (model.leftToLeft) {
            UIView *relationView = [pool getItemWithIdentifier:model.leftToLeft];
            CGFloat marginLeft = 0;
            if (model.marginLeft) {
                marginLeft = [DBDefines db_getUnit:model.marginLeft];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(relationView).offset(marginLeft);
            }];
        }
        
        if (model.rightToRight) {
            UIView *relationView = [pool getItemWithIdentifier:model.rightToRight];
            CGFloat marginRight = 0;
            if (model.marginRight) {
                marginRight = -[DBDefines db_getUnit:model.marginRight];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(relationView).offset(marginRight);
            }];
        }
        
        if (model.leftToRight) {
            UIView *relationView = [pool getItemWithIdentifier:model.leftToRight];
            CGFloat marginLeft = 0;
            if (model.marginLeft) {
                marginLeft = [DBDefines db_getUnit:model.marginLeft];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(relationView.mas_right).offset(marginLeft);
            }];
        }
        if (model.rightToLeft) {
            UIView *relationView = [pool getItemWithIdentifier:model.rightToLeft];
            CGFloat marginRight = 0;
            if (model.marginRight) {
                marginRight = -[DBDefines db_getUnit:model.marginRight];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(relationView.mas_left).offset(marginRight);
            }];
        }
    }
    
    //左右都有约束但间距都为0，则为居中或自适应的case
    if((model.topToTop || model.topToBottom)
       && (model.bottomToBottom || model.bottomToTop)
       &&  !model.marginTop && !model.marginBottom){

        UIView *tmpV = [UIView new];
        [view.superview addSubview:tmpV];
        
        UIView *topRelationView;
        if(model.topToTop){
            topRelationView = [pool getItemWithIdentifier:model.topToTop];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(topRelationView.mas_top);
            }];
        } else {
            topRelationView = [pool getItemWithIdentifier:model.topToBottom];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(topRelationView.mas_bottom);
            }];
        }
        
        UIView *bottomRelationView;
        if(model.bottomToTop){
            bottomRelationView = [pool getItemWithIdentifier:model.bottomToTop];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(bottomRelationView.mas_top);
            }];
        } else {
            bottomRelationView = [pool getItemWithIdentifier:model.bottomToBottom];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(bottomRelationView.mas_bottom);
            }];
        }
        
        if (model.height != nil && [DBDefines db_getUnit:model.height] == 0) {
            //写死0的case下，自适应
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(tmpV);
                make.bottom.mas_equalTo(tmpV);
            }];
        }else{
            if(topRelationView != bottomRelationView){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(tmpV);
                }];
            } else {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(topRelationView);
                }];
            }
        }
    } else{
        if (model.bottomToBottom) {
            UIView *relationView = [pool getItemWithIdentifier:model.bottomToBottom];
            CGFloat marginBottom = 0;
            if(model.marginBottom){
                marginBottom = -[DBDefines db_getUnit:model.marginBottom];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(relationView).offset(marginBottom);
            }];
        }
        if (model.topToTop) {
            UIView *relationView = [pool getItemWithIdentifier:model.topToTop];
            CGFloat marginTop = 0;
            if (model.marginTop) {
                marginTop = [DBDefines db_getUnit:model.marginTop];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(relationView).offset(marginTop);
            }];
        }
        
        if (model.bottomToTop) {
            UIView *relationView = [pool getItemWithIdentifier:model.bottomToTop];
            CGFloat marginBottom = 0;
            if (model.marginBottom) {
                marginBottom = -[DBDefines db_getUnit:model.marginBottom];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(relationView.mas_top).offset(marginBottom);
            }];
        }
        if (model.topToBottom) {
            UIView *relationView = [pool getItemWithIdentifier:model.topToBottom];
            CGFloat marginTop = 0;
            if (model.marginTop) {
                marginTop = [DBDefines db_getUnit:model.marginTop];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(relationView.mas_bottom).offset(marginTop);
            }];
        }
    }
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
                if ([DBParser isHandleDependOn:originDict andPathId:pathId]) { return;}  //如果有dependOn依赖
                Class cls = [[DBFactory sharedInstance] getActionClassByType:key];
                DBActions *act = [[cls alloc] init];
                if ([(NSObject<DBActionProtocol> *)act respondsToSelector:@selector(actWithDict:andPathId:)]) {
                    [(NSObject<DBActionProtocol> *)act actWithDict:originDict andPathId:pathId];
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
    if ([DBValidJudge isValidString:dependOnStr] && [self isMetaKey:dependOnStr]) {
        NSString *metakey = [DBParser paserStr:dependOnStr];
        NSDictionary *metaDict = [[DBPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId];
        NSString *key = [metaDict objectForKey:metakey];
        if ([DBValidJudge isValidString:key] && ![key isEqualToString:@"true"]) {
            return true;
        }
    }
    return false;
}


#pragma mark -
+ (BOOL)isMetaKey:(NSString *)key {
    if (![DBValidJudge isValidString:key] ) {
        return NO;
    }
    
    if ([key hasPrefix:@"${"] && [key hasSuffix:@"}"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEXTKey:(NSString *)key {
    
    if (![DBValidJudge isValidString:key] ) {
        return NO;
    }
    
    if ([key containsString:@"ext."]) {
        return YES;
    }
    
    return NO;
}


+ (BOOL)isGlobalPoolKey:(NSString *)key {
    
    if (![DBValidJudge isValidString:key] ) {
        return NO;
    }
    BOOL isPrefix = [key hasPrefix:@"${gp"] || [key hasPrefix:@"${GP"];
    if ( isPrefix && [key hasSuffix:@"}"]) {
        return YES;
    }
    return NO;
}

+ (id)getRealValueByPathId:(NSString *)pathId andKey:(NSString *)key{
    if (![DBValidJudge isValidString:key]) {
        return @"";
    }
    
    if ([DBParser isGlobalPoolKey:key]) {
        
        if ([key containsString:@"gp."]) {
             key = [key stringByReplacingOccurrencesOfString:@"gp." withString:@""];
         } else if ([key containsString:@"GP."]) {
             key = [key stringByReplacingOccurrencesOfString:@"GP." withString:@""];
         }
        
        NSString *paserKey = [DBParser paserStr:key];
        if ([[DBPool shareDBPool] getObjectFromDBGlobalPoolWithPathId:pathId]) {
            NSDictionary *GlobalPool = [[DBPool shareDBPool] getObjectFromDBGlobalPoolWithPathId:pathId];
            return [GlobalPool objectForKey:paserKey];
        }
    } else if ([DBParser isMetaKey:key]) {
        NSString *paserKey = [DBParser paserStr:key];
        if ([[DBPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId] != nil || [[DBPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId] != nil) {
            if ([DBParser isEXTKey:paserKey]) {
                NSDictionary *ext = [[DBPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId];
                NSString *extkey = [paserKey stringByReplacingOccurrencesOfString:@"ext." withString:@""];
                return [ext db_valueForPathId:extkey];
            }else{
                NSDictionary *meta = [[DBPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId];
                return [meta db_valueForPathId:paserKey];
            }
        }
        
    } else {
        return key;
    }
    
    return key;
}

+ (id)getMetaDictByPathId:(NSString *)pathId {
    if (![DBValidJudge isValidString:pathId]) {
        return nil;
    }
    return [[DBPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId];
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
    NSString *accessKey  = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    [[DBWrapperManager sharedManager] reportTid:pathId Key:@"tech_trace_node_unknown" accessKey:accessKey params:@{@"parent_node":@"",@"node_name":type?type:@""} frequency:DBReportFrequencyEVERY];
    //数据统计trace_node_unknown结束
}

+(void)trace_attr_unknown:(NSString *)type andPathId:(NSString *)pathId
{
    //包含未知节点,数据统计trace_node_unknown开始
    NSString *accessKey  = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    [[DBWrapperManager sharedManager] reportTid:pathId Key:@"tech_trace_attr_unknown" accessKey:accessKey params:@{@"attr_name":@"",@"node_name":type} frequency:DBReportFrequencyEVERY];
    //数据统计trace_node_unknown结束
}

+(void)trace_action_alias_not_found:(NSString *)alias_id andPathId:(NSString *)pathId
{
    //包含未知alias_id,数据统计trace_action_alias_not_found开始
    NSString *accessKey  = [[DBPool shareDBPool] getAccessKeyWithPathId:pathId];
    [[DBWrapperManager sharedManager] reportTid:pathId Key:@"tech_trace_action_alias_not_found" accessKey:accessKey params:@{@"alias_id":@""} frequency:DBReportFrequencyEVERY];
    //数据统计trace_action_alias_not_found结束
}

@end
