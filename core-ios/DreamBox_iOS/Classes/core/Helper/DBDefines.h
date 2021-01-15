//
//  DBUtility.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/17.
//  Copyright © 2020 didi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface DBDefines : NSObject

+ (NSString *)db_version;
+ (NSString *)db_report_version;
/*
 从字符串中获取确定的单位
*/
+ (CGFloat)db_getUnit:(NSString *)unitStr;


/// 获取uuid
+ (NSString *)uuidString;

+ (void)makeCornerWithView:(UIView *)view
                  cornerLT:(CGFloat)cornerLT
                  cornerRT:(CGFloat)cornerRT
                  cornerLB:(CGFloat)cornerLB
                  cornerRB:(CGFloat)cornerRB;

@end

NS_ASSUME_NONNULL_END
