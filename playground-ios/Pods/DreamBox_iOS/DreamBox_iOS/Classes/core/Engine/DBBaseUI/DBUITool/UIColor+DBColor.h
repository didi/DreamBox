//
//  UIColor+DBColor.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/19.
//  Copyright © 2020 didi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (DBColor)

+ (UIColor *)db_colorWithHexString:(NSString *)hexString;
//+(UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
