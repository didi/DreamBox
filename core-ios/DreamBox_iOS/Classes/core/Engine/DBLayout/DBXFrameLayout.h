//
//  DBFrameLayout.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import <Foundation/Foundation.h>
#import "DBXFrameModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXFrameLayout : NSObject

+ (UIEdgeInsets)contentRectEdgewithModel:(DBXFrameModel *)model pathId:(NSString *)pathId;

+ (void)frameLayoutWithView:(UIView *)view withModel:(DBXFrameModel *)model contentSize:(CGSize)size edgeInsets:(UIEdgeInsets)edgeInsets pathId:(NSString *)pathId;

@end

NS_ASSUME_NONNULL_END
