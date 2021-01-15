//
//  DBUtility.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/17.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBDefines.h"
#import "DBValidJudge.h"
static NSString * const kDreamBox_Report_Version = @"0.4.0";
static NSString * const kDreamBox_Version = @"0004";

@implementation DBDefines

// 0.1.0 = 000100 小版本不处理 每次发版需处理
+ (NSString *)db_version {
    return kDreamBox_Version;
}
+ (NSString *)db_report_version {
    return kDreamBox_Report_Version;
}

+ (CGFloat)db_getUnit:(NSString *)unitStr {
    
    if ([DBValidJudge isValidString:unitStr]) {
        if ([unitStr containsString:@"dp"]) {
            return unitStr.floatValue;
        }
        
        else if ([unitStr containsString:@"px"]) {
            CGFloat pxUnit = unitStr.floatValue;
            return pxUnit/[UIScreen mainScreen].scale;
        }
        
        else if([unitStr isEqualToString:@"fill"]) {
            return -1;
        }
        
        else if([unitStr isEqualToString:@"wrap"]) {
            return -1;
        }
        
        else {
            return unitStr.floatValue;
        }
    }
    return 0;
}

+ (NSString *)uuidString {
    
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef= CFUUIDCreateString(NULL, uuidRef);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
    CFRelease(uuidRef);
    CFRelease(uuidStringRef);
    
    return [uuid lowercaseString];
}

+ (void)makeCornerWithView:(UIView *)view
                  cornerLT:(CGFloat)cornerLT
                  cornerRT:(CGFloat)cornerRT
                  cornerLB:(CGFloat)cornerLB
                  cornerRB:(CGFloat)cornerRB{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = view.bounds;
    shapeLayer.path = [self cornerShapeWithRect:view.bounds
                                       cornerLT:cornerLT
                                       cornerRT:cornerRT
                                       cornerLB:cornerLB
                                       cornerRB:cornerRB
                       ];
    view.layer.mask = shapeLayer;
    view.layer.masksToBounds = YES;
}


+ (CGPathRef)cornerShapeWithRect:(CGRect)bounds
                        cornerLT:(CGFloat)cornerLT
                        cornerRT:(CGFloat)cornerRT
                        cornerLB:(CGFloat)cornerLB
                        cornerRB:(CGFloat)cornerRB
{
    const CGFloat minX = CGRectGetMinX(bounds);
    const CGFloat minY = CGRectGetMinY(bounds);
    const CGFloat maxX = CGRectGetMaxX(bounds);
    const CGFloat maxY = CGRectGetMaxY(bounds);
    
    const CGFloat topLeftCenterX = minX + cornerLT;
    const CGFloat topLeftCenterY = minY + cornerLT;
    
    const CGFloat topRightCenterX = maxX - cornerRT;
    const CGFloat topRightCenterY = minY + cornerRT;
    
    const CGFloat bottomLeftCenterX = minX + cornerLB;
    const CGFloat bottomLeftCenterY = maxY - cornerLB;
    
    const CGFloat bottomRightCenterX = maxX - cornerRB;
    const CGFloat bottomRightCenterY = maxY - cornerRB;
    //虽然顺时针参数是YES，在iOS中的UIView中，这里实际是逆时针
    
    CGMutablePathRef path = CGPathCreateMutable();
    //顶 左
    CGPathAddArc(path, NULL, topLeftCenterX, topLeftCenterY,cornerLT, M_PI, 3 * M_PI_2, NO);
    //顶 右
    CGPathAddArc(path, NULL, topRightCenterX , topRightCenterY, cornerRT, 3 * M_PI_2, 0, NO);
    //底 右
    CGPathAddArc(path, NULL, bottomRightCenterX, bottomRightCenterY, cornerRB,0, M_PI_2, NO);
    //底 左
    CGPathAddArc(path, NULL, bottomLeftCenterX, bottomLeftCenterY, cornerLB, M_PI_2,M_PI, NO);
    CGPathCloseSubpath(path);
    return path;
}
@end
