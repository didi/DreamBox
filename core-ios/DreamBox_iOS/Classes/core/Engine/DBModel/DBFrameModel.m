//
//  DBFrameModel.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/13.
//

#import "DBFrameModel.h"
#import "NSDictionary+DBExtends.h"

@implementation DBFrameModel

+ (DBFrameModel *)modelWithDict:(NSDictionary *)dict {
    DBFrameModel *model = [DBFrameModel new];
    model.width = [dict db_objectForKey:@"width"];
    model.height = [dict db_objectForKey:@"height"];
    model.marginLeft = [dict db_objectForKey:@"marginLeft"];
    model.marginTop = [dict db_objectForKey:@"marginTop"];
    return model;
}

@end
