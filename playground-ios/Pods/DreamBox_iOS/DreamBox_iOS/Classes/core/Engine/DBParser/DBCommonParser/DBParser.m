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
#import "DBButton.h"
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
    DBView *view = [[cls alloc] init];
    if ([(NSObject<DBViewProtocol> *)view respondsToSelector:@selector(setDataWithModel:andPathId:)]) {
        [(NSObject<DBViewProtocol> *)view setDataWithModel:model andPathId:pathId];
    }
    
    view.backgroundColor =  [UIColor db_colorWithHexString:model.backgroundColor];
    view.modelID = model.modelID;
    //处理点击
    view.onClick = model.onClick;
    
    if (model.visibleOn) {
        if ([[self getRealValueByPathId:pathId andKey:model.visibleOn] isEqualToString:@"false"]) {
            view.hidden = YES;
        }else{
            view.hidden = NO;
        }
    }

    if (view.onClick) {
        view.userInteractionEnabled = YES;
        __weak typeof(view) weakView = view;
        [view db_addTapGestureActionWithBlock:^(UITapGestureRecognizer * _Nonnull tapAction) {
            [self circulationActionDict:weakView.onClick  andPathId:pathId];
        }];
    } else {
        view.userInteractionEnabled = NO;
    }

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
    
    
//    view.translatesAutoresizingMaskIntoConstraints = NO;
    //宽
    if ([model.width floatValue] != 0) {
//        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[DBDefines db_getUnit:model.width]];
//        viewConstraint.active = YES;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([DBDefines db_getUnit:model.width]);
        }];
    }
    
    //高
    if ([model.height floatValue] != 0) {
//        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[DBDefines db_getUnit:model.height]];
//        viewConstraint.active = YES;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([DBDefines db_getUnit:model.height]);
        }];
    }
    
    //宽填满
    if ([model.width isEqualToString:@"fill"]) {
        UIView *relationView = [pool getItemWithIdentifier:@"0"];
//        relationView.translatesAutoresizingMaskIntoConstraints = NO;
//        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
//        viewConstraint.active = YES;
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(relationView.mas_width);
        }];
    }
    
    //高填满
    if ([model.height isEqualToString:@"fill"]) {
        UIView *relationView = [pool getItemWithIdentifier:@"0"];
//        relationView.translatesAutoresizingMaskIntoConstraints = NO;
//        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
//        viewConstraint.active = YES;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(relationView.mas_height);
        }];
    }
    
    //宽填满
    if (!model.width || [model.width isEqualToString:@"wrap"]) {
        //        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[view wrapSize].width];
        //        viewConstraint.active = YES;
        if(![view isKindOfClass:[DBText class]]){
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo([view wrapSize].width);
            }];
        }
    }
    
    //高填满
    if (!model.height || [model.height isEqualToString:@"wrap"]) {
        //        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[view wrapSize].height];
        //        viewConstraint.active = YES;
        if(![view isKindOfClass:[DBText class]]){
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo([view wrapSize].height);
            }];
        }
    }
    
    if ([model.leftToLeft isEqualToString:model.rightToRight] && !model.marginLeft && !model.marginRight) {
        UIView *relationView = [pool getItemWithIdentifier:model.leftToLeft];
//        relationView.translatesAutoresizingMaskIntoConstraints = NO;
        if (model.width != nil && [DBDefines db_getUnit:model.width] == 0) {
            //写死0的case下，自适应
//            NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
//            viewConstraint.active = YES;
//
//            NSLayoutConstraint *viewConstraint2 = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
//            viewConstraint2.active = YES;
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(relationView);
                make.right.mas_equalTo(relationView);
            }];
            
        }else{
//            NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
//            viewConstraint.active = YES;
            
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(relationView);
            }];
        }
    }else{
        if (model.leftToLeft) {
            UIView *relationView = [pool getItemWithIdentifier:model.leftToLeft];
//            relationView.translatesAutoresizingMaskIntoConstraints = NO;
            CGFloat marginLeft = 0;
            if (model.marginLeft) {
                marginLeft = [DBDefines db_getUnit:model.marginLeft];
            }
//            NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:marginLeft];
//            viewConstraint.active = YES;
            
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(relationView).offset(marginLeft);
            }];
        }
        
        if (model.rightToRight) {
            UIView *relationView = [pool getItemWithIdentifier:model.rightToRight];
//            relationView.translatesAutoresizingMaskIntoConstraints = NO;
            CGFloat marginRight = 0;
            if (model.marginRight) {
                marginRight = -[DBDefines db_getUnit:model.marginRight];
            }
//            NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeRight multiplier:1.0 constant:marginRight];
//            viewConstraint.active = YES;
            
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(relationView).offset(marginRight);
            }];
        }
    }

    if (model.leftToRight) {
        UIView *relationView = [pool getItemWithIdentifier:model.leftToRight];
//        relationView.translatesAutoresizingMaskIntoConstraints = NO;
        CGFloat marginLeft = 0;
        if (model.marginLeft) {
            marginLeft = [DBDefines db_getUnit:model.marginLeft];
        }
//        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeRight multiplier:1.0 constant:marginLeft];
//        viewConstraint.active = YES;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(relationView.mas_right).offset(marginLeft);
        }];
    }

    if (model.rightToLeft) {
        UIView *relationView = [pool getItemWithIdentifier:model.rightToLeft];
//        relationView.translatesAutoresizingMaskIntoConstraints = NO;
        CGFloat marginRight = 0;
        if (model.marginRight) {
            marginRight = -[DBDefines db_getUnit:model.marginRight];
        }
//        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:marginRight];
//        viewConstraint.active = YES;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(relationView.mas_left).offset(marginRight);
        }];
    }

    if ([model.bottomToBottom isEqualToString:model.topToTop] && !model.marginTop && !model.marginBottom) {
        UIView *relationView = [pool getItemWithIdentifier:model.bottomToBottom];
//        relationView.translatesAutoresizingMaskIntoConstraints = NO;

        if (model.height!= nil && [DBDefines db_getUnit:model.height] == 0) {
//            NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
//            viewConstraint.active = YES;
//
//            NSLayoutConstraint *viewConstraint2 = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
//            viewConstraint2.active = YES;
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(relationView);
                make.bottom.mas_equalTo(relationView);
            }];
        }else{
//            NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
//            viewConstraint.active = YES;
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(relationView);
            }];
        }
    }else{
        if (model.bottomToBottom) {
            UIView *relationView = [pool getItemWithIdentifier:model.bottomToBottom];
//            relationView.translatesAutoresizingMaskIntoConstraints = NO;
            CGFloat marginBottom = 0;
            if(model.marginBottom){
                marginBottom = -[DBDefines db_getUnit:model.marginBottom];
            }
//            NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:marginBottom];
//            viewConstraint.active = YES;
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(relationView).offset(marginBottom);
            }];
        }

        if (model.topToTop) {
            UIView *relationView = [pool getItemWithIdentifier:model.topToTop];
//            relationView.translatesAutoresizingMaskIntoConstraints = NO;
            CGFloat marginTop = 0;
            if (model.marginTop) {
                marginTop = [DBDefines db_getUnit:model.marginTop];
            }
//            NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeTop multiplier:1.0 constant:marginTop];
//            viewConstraint.active = YES;
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(relationView).offset(marginTop);
            }];
        }
    }

    if (model.bottomToTop) {
        UIView *relationView = [pool getItemWithIdentifier:model.bottomToTop];
//        relationView.translatesAutoresizingMaskIntoConstraints = NO;
        CGFloat marginBottom = 0;
        if (model.marginBottom) {
            marginBottom = -[DBDefines db_getUnit:model.marginBottom];
        }
//        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeTop multiplier:1.0 constant:marginBottom];
//        viewConstraint.active = YES;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(relationView.mas_top).offset(marginBottom);
        }];
    }

    if (model.topToBottom) {
        UIView *relationView = [pool getItemWithIdentifier:model.topToBottom];
//        relationView.translatesAutoresizingMaskIntoConstraints = NO;
        CGFloat marginTop = 0;
        if (model.marginTop) {
            marginTop = [DBDefines db_getUnit:model.marginTop];
        }
        
//        NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:relationView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:marginTop];
//        viewConstraint.active = YES;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(relationView.mas_bottom).offset(marginTop);
        }];
    }
}


//+ (UIViewController *)containerViewOfView:(UIView *)view
//{
//    id target=view;
//    while (target) {
//        target = ((UIResponder *)target).nextResponder;
//        if ([target isKindOfClass:[UIView class]]) {
//            break;
//        }
//    }
//    return target;
//}

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
