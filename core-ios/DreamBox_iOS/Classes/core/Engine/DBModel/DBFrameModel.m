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
    model.marginRight = [dict db_objectForKey:@"marginRight"];
    model.marginBottom = [dict db_objectForKey:@"marginBottom"];
    
    
    NSString *gravity = [dict db_objectForKey:@"gravity"];
    NSArray *gravityArr = [gravity componentsSeparatedByString:@"|"];
    __block DBFrameGravity gravityVal = DBFrameGravityStart;
    [gravityArr enumerateObjectsUsingBlock:^(NSString *gravityItem, NSUInteger idx, BOOL * _Nonnull stop) {
        DBFrameGravity gravityItemVal = [self frameGravityWithGravityStr:gravityItem];
        gravityVal |= gravityItemVal;
    }];
    model.gravity = gravityVal;
  
    return model;
}

+ (DBFrameGravity)frameGravityWithGravityStr:(NSString *)gravityStr{
    if([gravityStr isEqualToString:@"start"]){
        return DBFrameGravityStart;
    } else if([gravityStr isEqualToString:@"end"]){
        return DBFrameGravityEnd;
    } else if([gravityStr isEqualToString:@"top"]){
        return DBFrameGravityTop;
    } else if([gravityStr isEqualToString:@"bottom"]){
        return DBFrameGravityBottom;
    } else if([gravityStr isEqualToString:@"center"]){
        return DBFrameGravityCenter;
    } else if([gravityStr isEqualToString:@"center_vertical"]){
        return DBFrameGravityCentervertical;
    } else if([gravityStr isEqualToString:@"center_horizontal"]){
        return DBFrameGravityCenterHorizental;
    }
    return DBFrameGravityStart;
}

@end
