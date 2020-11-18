//
//  UIColor+DBColor.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/19.
//  Copyright © 2020 didi. All rights reserved.
//

#import "UIColor+DBColor.h"
#import "DBValidJudge.h"
@implementation UIColor (DBColor)


+ (UIColor *)db_colorWithHexString:(NSString *) hexString
{
    if (![DBValidJudge isValidString:hexString]) {
        return nil;
    }
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self db_colorComponentFrom: colorString start: 0 length: 1];
            green = [self db_colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self db_colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self db_colorComponentFrom: colorString start: 0 length: 1];
            red   = [self db_colorComponentFrom: colorString start: 1 length: 1];
            green = [self db_colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self db_colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self db_colorComponentFrom: colorString start: 0 length: 2];
            green = [self db_colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self db_colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self db_colorComponentFrom: colorString start: 0 length: 2];
            red   = [self db_colorComponentFrom: colorString start: 2 length: 2];
            green = [self db_colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self db_colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            blue=0;
            green=0;
            red=0;
            alpha=0;
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}
+ (CGFloat) db_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+(UIColor *)db_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha

{
    //删除字符串中的空格
    NSString*cString = [color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }

    // strip 0X if it appears

    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }

    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
   // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];

}

@end
