//
//  DBFrameModel.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DBFrameGravity) {
    DBFrameGravityStart = 1,
    DBFrameGravityEnd = 1 << 1,
    DBFrameGravityTop = 1 << 2,
    DBFrameGravityBottom = 1 << 3,
    DBFrameGravityCenter = 1 << 4,
    DBFrameGravityCenterHorizental = 1 << 5,
    DBFrameGravityCentervertical = 1 << 6
};

@interface DBFrameModel : NSObject

@property (nonatomic, copy) NSString *marginLeft;           //外边距
@property (nonatomic, copy) NSString *marginTop;
@property (nonatomic, copy) NSString *marginRight;
@property (nonatomic, copy) NSString *marginBottom;

@property (nonatomic, copy) NSString *paddingLeft;          //内边距
@property (nonatomic, copy) NSString *paddingTop;
@property (nonatomic, copy) NSString *paddingRight;
@property (nonatomic, copy) NSString *paddingBottom;
@property (nonatomic, copy) NSString *padding;

@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, assign) DBFrameGravity gravity;

+ (DBFrameModel *)modelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
