//
//  DBFrameModel.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBFrameModel : NSObject


@property (nonatomic, copy) NSString *marginLeft;
@property (nonatomic, copy) NSString *marginTop;
@property (nonatomic, copy) NSString *marginRight;
@property (nonatomic, copy) NSString *marginBottom;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *height;

+ (DBFrameModel *)modelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
