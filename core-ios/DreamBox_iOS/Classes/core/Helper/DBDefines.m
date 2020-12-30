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

@end
