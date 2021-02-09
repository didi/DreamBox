//
//  DBMonitor.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXMonitor.h"
#import "DBXLog.h"
@implementation DBXMonitor


+ (void)reportKey:(NSString *)key params:(NSDictionary<NSString *,NSString *> *)params {
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *theValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *reportString = [NSString stringWithFormat:@"%@ : %@",key,theValue];
    
    [DBXLog log:DBLogLevelInfo tag:@"report" msg:reportString];
}

@end
