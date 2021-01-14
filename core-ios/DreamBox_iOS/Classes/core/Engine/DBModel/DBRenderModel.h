//
//  DBRenderModel.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import <Foundation/Foundation.h>
#import "DBYogaModel.h"
#import "DBFrameModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBRenderModel : NSObject


@property (nonatomic, copy) NSString *backgroundColor;
@property (nonatomic, copy) NSString *_type;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, strong) DBYogaModel *yogaModel;
@property (nonatomic, strong) DBFrameModel *frameModel;

+ (DBRenderModel *)modelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
