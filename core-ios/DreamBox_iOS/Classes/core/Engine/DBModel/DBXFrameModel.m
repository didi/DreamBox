//
//  DBFrameModel.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/13.
//

#import "DBXFrameModel.h"
#import "NSDictionary+DBXExtends.h"

@implementation DBXFrameModel

+ (DBXFrameModel *)modelWithDict:(NSDictionary *)dict {
    DBXFrameModel *model = [DBXFrameModel new];
    model.width = [dict db_objectForKey:@"width"];
    model.height = [dict db_objectForKey:@"height"];
    model.marginLeft = [dict db_objectForKey:@"marginLeft"];
    model.marginTop = [dict db_objectForKey:@"marginTop"];
    model.marginRight = [dict db_objectForKey:@"marginRight"];
    model.marginBottom = [dict db_objectForKey:@"marginBottom"];
    
    model.paddingLeft = [dict db_objectForKey:@"paddingLeft"];
    model.paddingRight = [dict db_objectForKey:@"paddingRight"];
    model.paddingTop = [dict db_objectForKey:@"paddingTop"];
    model.paddingBottom = [dict db_objectForKey:@"paddingBottom"];
    model.padding = [dict db_objectForKey:@"padding"];
    
    NSString *gravity = [dict db_objectForKey:@"layoutGravity"];
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
    if([gravityStr isEqualToString:@"left"]){
        return DBFrameGravityStart;
    } else if([gravityStr isEqualToString:@"right"]){
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
