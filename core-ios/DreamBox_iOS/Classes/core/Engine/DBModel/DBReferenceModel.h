//
//  DBReferenceModel.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBReferenceModel : NSObject

//相对约束属性 V3.0
@property (nonatomic ,copy) NSString *leftToLeft;//id
@property (nonatomic ,copy) NSString *leftToRight;//id
@property (nonatomic ,copy) NSString *rightToRight;//id
@property (nonatomic ,copy) NSString *rightToLeft;//id
@property (nonatomic ,copy) NSString *topToTop;//id
@property (nonatomic ,copy) NSString *topToBottom;//id
@property (nonatomic ,copy) NSString *bottomToTop;//id
@property (nonatomic ,copy) NSString *bottomToBottom;//id

@property (nonatomic, copy) NSString *marginLeft;           //外边距
@property (nonatomic, copy) NSString *marginTop;
@property (nonatomic, copy) NSString *marginRight;
@property (nonatomic, copy) NSString *marginBottom;
@property (nonatomic, copy) NSString *margin;

@property (nonatomic, copy) NSString *paddingLeft;          //内边距
@property (nonatomic, copy) NSString *paddingTop;
@property (nonatomic, copy) NSString *paddingRight;
@property (nonatomic, copy) NSString *paddingBottom;
@property (nonatomic, copy) NSString *padding;

@property (nonatomic, copy) NSString *width;                //宽/高/最大最小限制
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *minWidth;
@property (nonatomic, copy) NSString *minHeight;
@property (nonatomic, copy) NSString *maxWidth;
@property (nonatomic, copy) NSString *maxHeight;

+ (DBReferenceModel *)modelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
