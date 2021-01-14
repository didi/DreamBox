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
    model._type = [dict db_objectForKey:@"_type"];
    model.type = [dict db_objectForKey:@"type"];
    model.children = [dict db_objectForKey:@"children"];
    
    return model;
}




@end
