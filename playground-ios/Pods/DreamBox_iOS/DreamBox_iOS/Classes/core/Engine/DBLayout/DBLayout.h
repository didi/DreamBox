//
//  DBLayout.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBLayout : NSObject

+ (void)edgeLayoutTargetView:(UIView *)targetView withReferenceView:(UIView *)referenceView edgeInset:(UIEdgeInsets)edgeInset;

@end

NS_ASSUME_NONNULL_END
