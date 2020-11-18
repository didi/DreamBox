//
//  DBLog.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBLog.h"
#import "DBHelper.h"
@implementation DBLog

+ (void)log:(DBLogLevel)level tag:(NSString *)tag msg:(NSString *)msg {
    
    switch (level) {
        case DBLogLevelError:
        case DBLogLevelWarning:
        case DBLogLevelInfo:
            
            [DBLog p_log:level tag:tag msg:msg];
            break;
        case DBLogLevelDebug:
        case DBLogLevelVerbose:
            
            [DBLog p_debugLog:level tag:tag msg:msg];
            break;
        default:
            [DBLog p_debugLog:level tag:tag msg:msg];
            break;
    }
}

+ (void)p_log:(DBLogLevel)level tag:(NSString *)tag msg:(NSString *)msg {
    
    NSLog(@"DB_level:(%ld) tag:(%@) msg:(%@)",(long)level,tag,msg);
}
+ (void)p_debugLog:(DBLogLevel)level tag:(NSString *)tag msg:(NSString *)msg {
#if DEBUG
    NSLog(@"DB_level:(%ld) tag:(%@) msg:(%@)",(long)level,tag,msg);
#endif
}


+ (DBLogLevel)logLevelByString:(NSString *)levelStr {
    
    if (![DBValidJudge isValidString:levelStr]) {
        return DBLogLevelDebug;
    }
    if ([levelStr isEqualToString:@"e"]) {
        return DBLogLevelError;
    } else if ([levelStr isEqualToString:@"w"]) {
        return DBLogLevelWarning;
    } else if ([levelStr isEqualToString:@"i"]) {
        return DBLogLevelInfo;
    } else if ([levelStr isEqualToString:@"d"]) {
        return DBLogLevelDebug;
    }else if ([levelStr isEqualToString:@"v"]) {
        return DBLogLevelVerbose;
    }
    
    return DBLogLevelDebug;
}

@end
