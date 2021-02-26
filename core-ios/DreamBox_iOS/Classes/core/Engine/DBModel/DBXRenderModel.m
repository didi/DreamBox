//
//  DBRenderModel.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import "DBXRenderModel.h"
#import "NSDictionary+DBXExtends.h"

@implementation DBXRenderModel

+ (DBXRenderModel *)modelWithDict:(NSDictionary *)dict{
    DBXRenderModel *model = (DBXRenderModel *)[super modelWithDict:dict];
    
    model.yogaModel = [DBXYogaModel modelWithDict:dict];
    model.frameModel = [DBXFrameModel modelWithDict:dict];

    model.background = [dict db_objectForKey:@"background"];
    return model;
}




@end
