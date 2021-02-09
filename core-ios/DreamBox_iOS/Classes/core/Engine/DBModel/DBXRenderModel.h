//
//  DBRenderModel.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import <Foundation/Foundation.h>
#import "DBXYogaModel.h"
#import "DBXFrameModel.h"
#import "DBXViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXRenderModel : DBXViewModel

@property (nonatomic, copy) NSString *background;

@property (nonatomic, strong) DBXYogaModel *yogaModel;
@property (nonatomic, strong) DBXFrameModel *frameModel;

+ (DBXRenderModel *)modelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
