//
//  DBRenderModel.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import "DBRenderModel.h"
#import "NSDictionary+DBExtends.h"

@implementation DBRenderModel

+ (DBRenderModel *)modelWithDict:(NSDictionary *)dict{
    DBRenderModel *model = [DBRenderModel new];
    
    model.yogaModel = [DBYogaModel modelWithDict:dict];
    model.frameModel = [DBFrameModel modelWithDict:dict];
    
    model.backgroundColor = [dict db_objectForKey:@"backgroundColor"];
    model.background = [dict db_objectForKey:@"background"];
    model._type = [dict db_objectForKey:@"_type"];
    model.type = [dict db_objectForKey:@"type"];
    model.children = [dict db_objectForKey:@"children"];
    
    model.width = [dict db_objectForKey:@"width"];
    model.height = [dict db_objectForKey:@"height"];
    model.radius = [dict db_objectForKey:@"radius"];
    model.radiusLT = [dict db_objectForKey:@"radiusLT"];
    model.radiusRT = [dict db_objectForKey:@"radiusRT"];
    model.radiusLB = [dict db_objectForKey:@"radiusLB"];
    model.radiusRB = [dict db_objectForKey:@"radiusRB"];
    
    return model;
}




@end
