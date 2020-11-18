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

@implementation DBViewModel

+ (DBViewModel *)modelWithDict:(NSDictionary *)dict
{
    NSString *type = [dict objectForKey:@"type"];
    Class cls = [[DBFactory sharedInstance] getModelClassByType:type];
    
//    DBViewModel *model = [cls mj_objectWithKeyValues:dict];
    
    //常规属性
    DBViewModel *model2 = [[cls alloc] init];
    model2.type = [dict db_objectForKey:@"type"];
    model2.modelID = [dict db_objectForKey:@"id"];
    model2.marginTop = [dict db_objectForKey:@"marginTop"];
    model2.marginBottom = [dict db_objectForKey:@"marginBottom"];
    model2.marginLeft = [dict db_objectForKey:@"marginLeft"];
    model2.marginRight = [dict db_objectForKey:@"marginRight"];
    
    model2.paddingTop = [dict db_objectForKey:@"paddingTop"];
    model2.paddingLeft = [dict db_objectForKey:@"paddingLeft"];
    model2.paddingRight = [dict db_objectForKey:@"paddingRight"];
    model2.paddingBottom = [dict db_objectForKey:@"paddingBottom"];
    
    model2.backgroundColor = [dict db_objectForKey:@"backgroundColor"];
    model2.width = [dict db_objectForKey:@"width"];
    model2.height = [dict db_objectForKey:@"height"];
    model2.visibleOn = [dict db_objectForKey:@"visibleOn"];
    //布局约束属性
    model2.leftToLeft = [dict db_objectForKey:@"leftToLeft"];
    model2.leftToRight = [dict db_objectForKey:@"leftToRight"];
    model2.rightToRight = [dict db_objectForKey:@"rightToRight"];
    model2.rightToLeft = [dict db_objectForKey:@"rightToLeft"];
    model2.topToTop = [dict db_objectForKey:@"topToTop"];
    model2.topToBottom = [dict db_objectForKey:@"topToBottom"];
    model2.bottomToTop = [dict db_objectForKey:@"bottomToTop"];
    model2.bottomToBottom = [dict db_objectForKey:@"bottomToBottom"];

    //DSLv2.0
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
    //触发事件节点
//    model2.onClick = [dict db_objectForKey:@"onClick"];
//    model2.onVisible = [dict db_objectForKey:@"onVisible"];
//    model2.onInvisible = [dict db_objectForKey:@"onInvisible"];
    
    return model2;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"modelID":@"id"};
}

@end

@implementation DBTreeModel
- (NSArray *)render{
    if(_render){
        return _render;
    } else {
        return self.children;
    }
}

@end

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

@implementation DBListModel

+ (DBListModel *)modelWithDict:(NSDictionary *)dict
{
    //常规属性DSLv1.0
    DBListModel *model = (DBListModel *)[super modelWithDict:dict];
    model.src = [dict objectForKey:@"src"];
    model.pullRefresh = [dict objectForKey:@"pullRefresh"];
    model.loadMore = [dict objectForKey:@"loadMore"];
    model.pageIndex = [dict objectForKey:@"pageIndex"];
    model.onPull = [dict objectForKey:@"onPull"];
    model.onMore = [dict objectForKey:@"onMore"];
    model.orientation = [dict objectForKey:@"orientation"];

    NSArray *children = [dict objectForKey:@"children"];
    [children enumerateObjectsUsingBlock:^( NSDictionary *itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *type = [itemDict objectForKey:@"type"];
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

