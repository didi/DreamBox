//
//  DBModel.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBViewModel.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "DBViewModel.h"
#import "DBFactory.h"
#import "NSDictionary+DBExtends.h"
#import "DBYogaModel.h"
#import "DBReferenceModel.h"
#import "DBRenderModel.h"

@implementation DBViewModel

#pragma mark - viewModel
+ (DBViewModel *)modelWithDict:(NSDictionary *)dict
{
    NSString *type = [dict objectForKey:@"_type"];
    Class cls = [[DBFactory sharedInstance] getModelClassByType:type];
    //常规属性
    DBViewModel *model2 = [[cls alloc] init];
    model2._type = [dict db_objectForKey:@"_type"];
    model2.type = [dict db_objectForKey:@"type"];
    model2.modelID = [dict db_objectForKey:@"id"];
    model2.backgroundColor = [dict db_objectForKey:@"backgroundColor"];
    model2.visibleOn = [dict db_objectForKey:@"visibleOn"];
    model2.shape = [dict db_objectForKey:@"shape"];
    model2.radius = [dict db_objectForKey:@"radius"];
    model2.borderWidth = [dict db_objectForKey:@"borderWidth"];
    model2.borderColor = [dict db_objectForKey:@"borderColor"];
    model2.gradientColor = [dict db_objectForKey:@"gradientColor"];
    model2.gradientOrientation = [dict db_objectForKey:@"gradientOrientation"];
    model2.children = [dict db_objectForKey:@"children"];
    model2.changeOn = [dict db_objectForKey:@"changeOn"];
    
    model2.callbacks = [dict db_objectForKey:@"callbacks"];
    model2.userInteractionEnabled = [dict db_objectForKey:@"userInteractionEnabled"];
    model2.radiusRT = [dict db_objectForKey:@"radiusRT"];
    model2.radiusLT = [dict db_objectForKey:@"radiusLT"];
    model2.radiusRB = [dict db_objectForKey:@"radiusRB"];
    model2.radiusLB = [dict db_objectForKey:@"radiusLB"];
    
    NSInteger dbVersion = 4;
    if(dbVersion >= 4){
        DBYogaModel *yogaLayout = [DBYogaModel modelWithDict:dict];
        model2.yogaLayout = yogaLayout;
        
        DBFrameModel *frameLayout = [DBFrameModel modelWithDict:dict];
        model2.frameLayout = frameLayout;
    } else {
        DBReferenceModel *referenceLayout = [DBReferenceModel modelWithDict:dict];
        model2.referenceLayout = referenceLayout;
    }
    
    return model2;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"modelID":@"id"};
}

@end


#pragma mark - treeModel
@implementation DBTreeModel

+ (id)modelWithDict:(NSDictionary *)dict type:(DBTreeModelLayoutType)type{
    DBTreeModel *treeModel;
    if(type == DBTreeModelLayoutTypeReference){
        treeModel = [[DBTreeModelReference alloc] init];
    } else {
        treeModel = [[DBTreeModelYoga alloc] init];
    }

    treeModel.displayType = [dict db_objectForKey:@"displayType"];
    treeModel.width = [dict db_objectForKey:@"width"];
    treeModel.height = [dict db_objectForKey:@"height"];
    treeModel.dismissOn = [dict db_objectForKey:@"dismissOn"];
    treeModel.onVisible = [dict db_objectForKey:@"onVisible"];
    treeModel.onInvisible = [dict db_objectForKey:@"onInvisible"];
    treeModel.meta = [dict db_objectForKey:@"meta"];
    treeModel.actionAlias = [dict db_objectForKey:@"actionAlias"];
    treeModel.onEvent = [dict db_objectForKey:@"onEvent"];
    treeModel.scroll = [dict db_objectForKey:@"scroll"];
    treeModel.callbacks = [dict db_objectForKey:@"callbacks"];
    
    return treeModel;
}

@end


@implementation DBTreeModelReference

+ (DBTreeModelReference *)modelWithDict:(NSDictionary *)dict{
    DBTreeModelReference *model = [super modelWithDict:dict type:DBTreeModelLayoutTypeReference];
    
    model.render = [dict db_objectForKey:@"render"]; //相对布局中render为数组
    
    return model;
}

- (NSArray *)render{
    if(_render){
        return _render;
    } else {
        return self.children;
    }
}

@end

@implementation DBTreeModelYoga

+ (DBTreeModelYoga *)modelWithDict:(NSDictionary *)dict{
    DBTreeModelYoga *model = [super modelWithDict:dict type:DBTreeModelLayoutTypeYoga];
    
    NSDictionary *renderDict = [dict db_objectForKey:@"layout"];
    DBRenderModel *render = [DBRenderModel modelWithDict:renderDict]; //yoga布局中render为yoga模型
    model.render = render;
    
    return model;
}

@end


#pragma mark - item view Model
@implementation DBTextModel

+ (DBTextModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBTextModel *model = (DBTextModel *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.size = [dict objectForKey:@"size"];
    model.color = [dict objectForKey:@"color"];
    model.style = [dict objectForKey:@"style"];
    //常规属性DSLv2.0
    model.gravity = [dict db_objectForKey:@"gravity"];
    model.maxLines = [dict db_objectForKey:@"maxLines"];
    model.ellipsize = [dict db_objectForKey:@"ellipsize"];
    model.maxWidth = [dict db_objectForKey:@"maxWidth"];
    model.minWidth = [dict db_objectForKey:@"minWidth"];
    model.maxHeight = [dict db_objectForKey:@"maxHeight"];
    model.minHeight = [dict db_objectForKey:@"minHeight"];
    
    return model;
}

@end


@implementation DBImageModel

+ (DBImageModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBImageModel *model = (DBImageModel *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.scaleType = [dict objectForKey:@"scaleType"];
    model.srcType = [dict objectForKey:@"srcType"];
    return model;
}

@end


@implementation DBLoadingModel

+ (DBLoadingModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBLoadingModel *model = (DBLoadingModel *)[super modelWithDict:dict];
    model.style = [dict objectForKey:@"style"];
    return model;
}

@end

@implementation DBProgressModel

+ (DBProgressModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBProgressModel *model = (DBProgressModel *)[super modelWithDict:dict];
    model.value = [dict objectForKey:@"value"];
    model.barBg = [dict objectForKey:@"barBg"];
    model.barFg = [dict objectForKey:@"barFg"];
    model.barBgColor = [dict objectForKey:@"barBgColor"];
    model.barFgColor = [dict objectForKey:@"barFgColor"];
    model.patchType = [dict objectForKey:@"patchType"];
    model.radius = [dict objectForKey:@"radius"];
    return model;
}

@end

@implementation DBlistModel

+ (DBlistModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBlistModel *model = (DBlistModel *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.pullRefresh = [dict objectForKey:@"pullRefresh"];
    model.loadMore = [dict objectForKey:@"loadMore"];
    model.pageIndex = [dict objectForKey:@"pageIndex"];
    model.onPull = [dict objectForKey:@"onPull"];
    model.onMore = [dict objectForKey:@"onMore"];
    model.orientation = [dict objectForKey:@"orientation"];

    NSArray *children = [dict objectForKey:@"children"];
    [children enumerateObjectsUsingBlock:^( NSDictionary *itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *type = [itemDict objectForKey:@"_type"];
        if([type isEqualToString:@"header"]){
            model.header = (NSArray *)[itemDict objectForKey:@"children"];
        }
        if([type isEqualToString:@"footer"]){
            model.footer = (NSArray *)[itemDict objectForKey:@"children"];
        }
        if([type isEqualToString:@"vh"]){
            model.vh = (NSArray *)[itemDict objectForKey:@"children"];
        }
    }];
    return model;
}

@end

@implementation DBlistModelV2

+ (DBlistModelV2 *)modelWithDict:(NSDictionary *)dict
{
    DBlistModelV2 *model = (DBlistModelV2 *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.pullRefresh = [dict objectForKey:@"pullRefresh"];
    model.loadMore = [dict objectForKey:@"loadMore"];
    model.pageIndex = [dict objectForKey:@"pageIndex"];
    model.onPull = [dict objectForKey:@"onPull"];
    model.onMore = [dict objectForKey:@"onMore"];
    model.orientation = [dict objectForKey:@"orientation"];
    

    NSArray *children = [dict objectForKey:@"children"];
    model.children = children;
    
    [children enumerateObjectsUsingBlock:^(NSDictionary *itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *type = [itemDict db_objectForKey:@"payload"];
        if([type isEqualToString:@"header"]){
            model.header = itemDict;
        }
        if([type isEqualToString:@"footer"]){
            model.footer = itemDict;
        }
        if([type isEqualToString:@"vh"]){
            model.vh = itemDict;
        }
    }];
   
    return model;
}

@end

@implementation DBFlowModel

+ (DBFlowModel *)modelWithDict:(NSDictionary *)dict{
    DBFlowModel *model = (DBFlowModel *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.hSpace = [dict objectForKey:@"hSpace"];
    model.vSpace = [dict objectForKey:@"vSpace"];
    model.children = [dict objectForKey:@"children"];
    return model;
}
@end

