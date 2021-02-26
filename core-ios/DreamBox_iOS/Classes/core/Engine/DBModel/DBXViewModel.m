//
//  DBModel.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXViewModel.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "DBXViewModel.h"
#import "DBXFactory.h"
#import "NSDictionary+DBXExtends.h"
#import "DBXYogaModel.h"
#import "DBXRenderModel.h"

@implementation DBXViewModel

#pragma mark - viewModel
+ (DBXViewModel *)modelWithDict:(NSDictionary *)dict
{
    NSString *type = [dict objectForKey:@"_type"];
    Class cls = [[DBXFactory sharedInstance] getModelClassByType:type];
    //常规属性
    DBXViewModel *model2 = [[cls alloc] init];
    model2._type = [dict db_objectForKey:@"_type"];
    model2.type = [dict db_objectForKey:@"type"];
    model2.modelID = [NSString stringWithFormat:@"%@",[dict db_objectForKey:@"_id"]];
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
    model2.width = [dict db_objectForKey:@"width"];
    model2.height = [dict db_objectForKey:@"height"];
    
    DBXYogaModel *yogaLayout = [DBXYogaModel modelWithDict:dict];
    model2.yogaLayout = yogaLayout;
    
    DBXFrameModel *frameLayout = [DBXFrameModel modelWithDict:dict];
    model2.frameLayout = frameLayout;
    
    return model2;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"modelID":@"id"};
}

@end


#pragma mark - treeModel
@implementation DBXTreeModel

+ (id)modelWithDict:(NSDictionary *)dict type:(DBTreeModelLayoutType)type{
    DBXTreeModelYoga *treeModel = [[DBXTreeModelYoga alloc] init];

    treeModel.meta = [dict db_objectForKey:@"meta"];
    treeModel.actionAlias = [dict db_objectForKey:@"actionAlias"];
    treeModel.onEvent = [dict db_objectForKey:@"onEvent"];
    treeModel.scroll = [dict db_objectForKey:@"scroll"];
    
    return treeModel;
}

@end

@implementation DBXTreeModelYoga

+ (DBXTreeModelYoga *)modelWithDict:(NSDictionary *)dict{
    DBXTreeModelYoga *model = [super modelWithDict:dict type:DBTreeModelLayoutTypeYoga];
    
    NSDictionary *renderDict = [dict db_objectForKey:@"layout"];
    DBXRenderModel *render = [DBXRenderModel modelWithDict:renderDict]; //yoga布局中render为yoga模型
    model.render = render;
    
    return model;
}

@end


#pragma mark - item view Model
@implementation DBXTextModel

+ (DBXTextModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBXTextModel *model = (DBXTextModel *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.size = [dict objectForKey:@"size"];
    model.color = [dict objectForKey:@"color"];
    model.style = [dict objectForKey:@"style"];
    //常规属性DSLv2.0
    model.gravity = [dict db_objectForKey:@"gravity"];
    model.maxLines = [dict db_objectForKey:@"maxLines"];
    model.ellipsize = [dict db_objectForKey:@"ellipsize"];
    
    return model;
}

@end


@implementation DBXImageModel

+ (DBXImageModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBXImageModel *model = (DBXImageModel *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.scaleType = [dict objectForKey:@"scaleType"];
    model.srcType = [dict objectForKey:@"srcType"];
    return model;
}

@end


@implementation DBXLoadingModel

+ (DBXLoadingModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBXLoadingModel *model = (DBXLoadingModel *)[super modelWithDict:dict];
    model.style = [dict objectForKey:@"style"];
    return model;
}

@end

@implementation DBXProgressModel

+ (DBXProgressModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBXProgressModel *model = (DBXProgressModel *)[super modelWithDict:dict];
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

@implementation DBXlistModelV2

+ (DBXlistModelV2 *)modelWithDict:(NSDictionary *)dict
{
    DBXlistModelV2 *model = (DBXlistModelV2 *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.pullRefresh = [dict objectForKey:@"pullRefresh"];
    model.loadMore = [dict objectForKey:@"loadMore"];
    model.pageIndex = [dict objectForKey:@"pageIndex"];
    model.onPull = [dict objectForKey:@"onPull"];
    model.onMore = [dict objectForKey:@"onMore"];
    model.orientation = [dict objectForKey:@"orientation"];
    model.vSpace = [dict objectForKey:@"vSpace"];
    model.hSpace = [dict objectForKey:@"hSpace"];
    model.edgeStart = [dict objectForKey:@"edgeStart"];
    model.edgeEnd = [dict objectForKey:@"edgeEnd"];

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

@implementation DBXFlowModel

+ (DBXFlowModel *)modelWithDict:(NSDictionary *)dict{
    DBXFlowModel *model = (DBXFlowModel *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.hSpace = [dict objectForKey:@"hSpace"];
    model.vSpace = [dict objectForKey:@"vSpace"];
    model.children = [dict objectForKey:@"children"];
    return model;
}
@end

