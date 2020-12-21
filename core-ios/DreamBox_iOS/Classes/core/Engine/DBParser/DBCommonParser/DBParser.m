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
#import "NSArray+DBExtends.h"
#import "DBFlexBoxLayout.h"

#import "DBViewModel.h"
#import "DBReferenceModel.h"
#import "DBYogaModel.h"

@implementation DBParser

+(DBTreeModel *)parserDict:(NSDictionary *)dict
{
    NSDictionary *dictAll = [dict objectForKey:@"dbl"];
    
    DBTreeModel *treeModel;
    
    int dbVersion = 4;
    if(dbVersion >= 4){
        treeModel = [DBTreeModelYoga modelWithDict:dictAll];
    } else {
        treeModel = [DBTreeModelReference modelWithDict:dictAll];
        treeModel.isSubTree = [dict db_objectForKey:@"isSubTree"];
    }
    
    return treeModel;
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
    
    if ([(NSObject<DBViewProtocol> *)view respondsToSelector:@selector(onCreateView)]) {
        [(NSObject<DBViewProtocol> *)view onCreateView];
    }
    
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
    
    if(model.backgroundColor){
        view.backgroundColor =  [UIColor db_colorWithHexString:model.backgroundColor];
    }
    
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
    DBReferenceModel *referenceLayout = model.referenceLayout;
    //处理children的布局
    //宽
    if ([referenceLayout.width floatValue] != 0) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([DBDefines db_getUnit:referenceLayout.width]);
        }];
    }
    
    //高
    if ([referenceLayout.height floatValue] != 0) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([DBDefines db_getUnit:referenceLayout.height]);
        }];
    }
    
    //宽填满
    if ([referenceLayout.width isEqualToString:@"fill"]) {
        UIView *relationView = [pool getItemWithIdentifier:@"0"];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(relationView.mas_width);
        }];
    }
    
    //高填满
    if ([referenceLayout.height isEqualToString:@"fill"]) {
        UIView *relationView = [pool getItemWithIdentifier:@"0"];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(relationView.mas_height);
        }];
    }
    
    if (!referenceLayout.width || [referenceLayout.width isEqualToString:@"wrap"]) {
        CGSize size = [view wrapSize];
        if([view isKindOfClass:[DBText class]]){
            if(size.height > 0 && size.width > 0){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(size);
                }];
            }
        } else {
            if(size.width > 0){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(size.width);
                }];
            }
        }
    }
    
    if (!referenceLayout.height || [referenceLayout.height isEqualToString:@"wrap"]) {
        CGSize size = [view wrapSize];
        if([view isKindOfClass:[DBText class]]){
            if(size.height > 0 && size.width > 0){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(size);
                }];
            }
        } else {
            if(size.height > 0){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(size.height);
                }];
            }
        }
    }
    
    if((referenceLayout.leftToLeft || referenceLayout.leftToRight)
       && (referenceLayout.rightToRight || referenceLayout.rightToLeft)
       &&  !referenceLayout.marginLeft && !referenceLayout.marginRight){

        UIView *tmpV = [UIView new];
        [view.superview addSubview:tmpV];
        
        UIView *leftRelationView;
        if(referenceLayout.leftToRight){
            leftRelationView = [pool getItemWithIdentifier:referenceLayout.leftToRight];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(leftRelationView.mas_right);
            }];
        } else {
            leftRelationView = [pool getItemWithIdentifier:referenceLayout.leftToLeft];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(leftRelationView.mas_left);
            }];
        }
        
        UIView *rightRelationView;
        if(referenceLayout.rightToLeft){
            rightRelationView = [pool getItemWithIdentifier:referenceLayout.rightToLeft];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightRelationView.mas_left);
            }];
        } else {
            rightRelationView = [pool getItemWithIdentifier:referenceLayout.rightToRight];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightRelationView.mas_right);
            }];
        }
        
        if (referenceLayout.width != nil && [DBDefines db_getUnit:referenceLayout.width] == 0) {
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
        if (referenceLayout.leftToLeft) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.leftToLeft];
            CGFloat marginLeft = 0;
            if (referenceLayout.marginLeft) {
                marginLeft = [DBDefines db_getUnit:referenceLayout.marginLeft];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(relationView).offset(marginLeft);
            }];
        }
        
        if (referenceLayout.rightToRight) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.rightToRight];
            CGFloat marginRight = 0;
            if (referenceLayout.marginRight) {
                marginRight = -[DBDefines db_getUnit:referenceLayout.marginRight];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(relationView).offset(marginRight);
            }];
        }
        
        if (referenceLayout.leftToRight) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.leftToRight];
            CGFloat marginLeft = 0;
            if (referenceLayout.marginLeft) {
                marginLeft = [DBDefines db_getUnit:referenceLayout.marginLeft];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(relationView.mas_right).offset(marginLeft);
            }];
        }
        if (referenceLayout.rightToLeft) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.rightToLeft];
            CGFloat marginRight = 0;
            if (referenceLayout.marginRight) {
                marginRight = -[DBDefines db_getUnit:referenceLayout.marginRight];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(relationView.mas_left).offset(marginRight);
            }];
        }
    }
    
    //左右都有约束但间距都为0，则为居中或自适应的case
    if((referenceLayout.topToTop || referenceLayout.topToBottom)
       && (referenceLayout.bottomToBottom || referenceLayout.bottomToTop)
       &&  !referenceLayout.marginTop && !referenceLayout.marginBottom){

        UIView *tmpV = [UIView new];
        [view.superview addSubview:tmpV];
        
        UIView *topRelationView;
        if(referenceLayout.topToTop){
            topRelationView = [pool getItemWithIdentifier:referenceLayout.topToTop];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(topRelationView.mas_top);
            }];
        } else {
            topRelationView = [pool getItemWithIdentifier:referenceLayout.topToBottom];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(topRelationView.mas_bottom);
            }];
        }
        
        UIView *bottomRelationView;
        if(referenceLayout.bottomToTop){
            bottomRelationView = [pool getItemWithIdentifier:referenceLayout.bottomToTop];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(bottomRelationView.mas_top);
            }];
        } else {
            bottomRelationView = [pool getItemWithIdentifier:referenceLayout.bottomToBottom];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(bottomRelationView.mas_bottom);
            }];
        }
        
        if (referenceLayout.height != nil && [DBDefines db_getUnit:referenceLayout.height] == 0) {
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
        if (referenceLayout.bottomToBottom) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.bottomToBottom];
            CGFloat marginBottom = 0;
            if(referenceLayout.marginBottom){
                marginBottom = -[DBDefines db_getUnit:referenceLayout.marginBottom];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(relationView).offset(marginBottom);
            }];
        }
        if (referenceLayout.topToTop) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.topToTop];
            CGFloat marginTop = 0;
            if (referenceLayout.marginTop) {
                marginTop = [DBDefines db_getUnit:referenceLayout.marginTop];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(relationView).offset(marginTop);
            }];
        }
        
        if (referenceLayout.bottomToTop) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.bottomToTop];
            CGFloat marginBottom = 0;
            if (referenceLayout.marginBottom) {
                marginBottom = -[DBDefines db_getUnit:referenceLayout.marginBottom];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(relationView.mas_top).offset(marginBottom);
            }];
        }
        if (referenceLayout.topToBottom) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.topToBottom];
            CGFloat marginTop = 0;
            if (referenceLayout.marginTop) {
                marginTop = [DBDefines db_getUnit:referenceLayout.marginTop];
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
                    finalValue = [finalValue stringByReplacingOccurrencesOfString:originKey withString:realValue];
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

+ (void)flexLayoutView:(UIView *)view withModel:(DBYogaModel *)model{
    [view configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        if(model.flexDirection.length > 0){
            layout.flexDirection = [DBFlexBoxLayout flexDirectionWithKey:model.flexDirection];
        }
        if(model.justifyContent.length > 0){
            layout.justifyContent = [DBFlexBoxLayout justifyWithKey:model.justifyContent];
        }
        if(model.alignContent.length > 0){
            layout.alignContent = [DBFlexBoxLayout alignWithKey:model.alignContent];
        }
        if(model.alignItems.length > 0){
            layout.alignItems = [DBFlexBoxLayout alignWithKey:model.alignItems];
        }
        if(model.alignSelf.length > 0){
            layout.alignSelf = [DBFlexBoxLayout alignWithKey:model.alignSelf];
        }
        if(model.position.length > 0){
            layout.position = [DBFlexBoxLayout positionTypeWithKey:model.position];
        }
        if(model.flexWrap.length > 0){
            layout.flexWrap = [DBFlexBoxLayout wrapWithKey:model.flexWrap];
        }
        if(model.overflow.length > 0){
            layout.overflow = [DBFlexBoxLayout overflowWithKey:model.overflow];
        }
        if(model.display.length > 0){
            layout.display = [DBFlexBoxLayout displayWithKey:model.display];
        }
        if(model.flexGrow.length > 0){
            layout.flexGrow = [DBDefines db_getUnit:model.flexGrow];
        }
        if(model.flexShrink.length > 0){
            layout.flexShrink = [DBDefines db_getUnit:model.flexShrink];
        }
        
        if(model.flexBasis.length > 0){
            if([model.flexBasis containsString:@"%"]){
                layout.flexBasis = YGPercentValue([DBDefines db_getUnit:model.flexBasis]);
            } else {
                layout.flexBasis = YGPointValue([DBDefines db_getUnit:model.flexBasis]);
            }
        }
        
        if(model.left.length > 0){
            layout.left = YGPointValue([DBDefines db_getUnit:model.left]);
        }
        if(model.top.length > 0){
            layout.top = YGPointValue([DBDefines db_getUnit:model.top]);
        }
        if(model.right.length > 0){
            layout.right = YGPointValue([DBDefines db_getUnit:model.right]);
        }
        if(model.bottom.length > 0){
            layout.bottom = YGPointValue([DBDefines db_getUnit:model.bottom]);
        }
        if(model.start.length > 0){
            layout.start = YGPointValue([DBDefines db_getUnit:model.start]);
        }
        if(model.end.length > 0){
            layout.end = YGPointValue([DBDefines db_getUnit:model.end]);
        }
        if(model.marginLeft.length > 0){
            layout.marginLeft = YGPointValue([DBDefines db_getUnit:model.marginLeft]);
        }
        if(model.marginTop.length > 0){
            layout.marginTop = YGPointValue([DBDefines db_getUnit:model.marginTop]);
        }
        if(model.marginRight.length > 0){
            layout.marginRight = YGPointValue([DBDefines db_getUnit:model.marginRight]);
        }
        if(model.marginBottom.length > 0){
            layout.marginBottom = YGPointValue([DBDefines db_getUnit:model.marginBottom]);
        }
        if(model.marginStart.length > 0){
            layout.marginStart = YGPointValue([DBDefines db_getUnit:model.marginStart]);
        }
        if(model.marginEnd.length > 0){
            layout.marginEnd = YGPointValue([DBDefines db_getUnit:model.marginEnd]);
        }
        if(model.marginHorizontal.length > 0){
            layout.marginHorizontal = YGPointValue([DBDefines db_getUnit:model.marginHorizontal]);
        }
        if(model.marginVertical.length > 0){
            layout.marginVertical = YGPointValue([DBDefines db_getUnit:model.marginVertical]);
        }
        if(model.margin.length > 0){
            layout.margin = YGPointValue([DBDefines db_getUnit:model.margin]);
        }
        if(model.paddingLeft.length > 0){
            layout.paddingLeft = YGPointValue([DBDefines db_getUnit:model.paddingLeft]);
        }
        if(model.paddingTop.length > 0){
            layout.paddingTop = YGPointValue([DBDefines db_getUnit:model.paddingTop]);
        }
        if(model.paddingRight.length > 0){
            layout.paddingRight = YGPointValue([DBDefines db_getUnit:model.paddingRight]);
        }
        if(model.paddingBottom.length > 0){
            layout.paddingBottom = YGPointValue([DBDefines db_getUnit:model.paddingBottom]);
        }
        if(model.paddingStart.length > 0){
            layout.paddingStart = YGPointValue([DBDefines db_getUnit:model.paddingStart]);
        }
        if(model.paddingEnd.length > 0){
            layout.paddingEnd = YGPointValue([DBDefines db_getUnit:model.paddingEnd]);
        }
        if(model.paddingHorizontal.length > 0){
            layout.paddingHorizontal = YGPointValue([DBDefines db_getUnit:model.paddingHorizontal]);
        }
        if(model.paddingVertical.length > 0){
            layout.paddingVertical = YGPointValue([DBDefines db_getUnit:model.paddingVertical]);
        }
        if(model.padding.length > 0){
            layout.padding = YGPointValue([DBDefines db_getUnit:model.padding]);
        }
        if(model.width.length > 0){
            layout.width = YGPointValue([DBDefines db_getUnit:model.width]);
        }
        if(model.height.length > 0){
            layout.height = YGPointValue([DBDefines db_getUnit:model.height]);
        }
        if(model.minWidth.length > 0){
            layout.minWidth = YGPointValue([DBDefines db_getUnit:model.minWidth]);
        }
        if(model.minHeight.length > 0){
            layout.minHeight = YGPointValue([DBDefines db_getUnit:model.minHeight]);
        }
        if(model.maxWidth.length > 0){
            layout.maxWidth = YGPointValue([DBDefines db_getUnit:model.maxWidth]);
        }
        if(model.maxHeight.length > 0){
            layout.maxHeight = YGPointValue([DBDefines db_getUnit:model.maxHeight]);
        }
    }];
}

+ (void)applyLayoutToView:(UIView *)view rreservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility {
    [view.yoga applyLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
}

@end
