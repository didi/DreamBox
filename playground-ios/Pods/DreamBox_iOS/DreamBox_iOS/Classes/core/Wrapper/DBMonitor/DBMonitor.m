//
//  DBMonitor.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBMonitor.h"
#import "DBLog.h"
@implementation DBMonitor


+ (void)reportKey:(NSString *)key params:(NSDictionary<NSString *,NSString *> *)params {
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *theValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *reportString = [NSString stringWithFormat:@"%@ : %@",key,theValue];
    
    [DBLog log:DBLogLevelInfo tag:@"report" msg:reportString];
}

@end
