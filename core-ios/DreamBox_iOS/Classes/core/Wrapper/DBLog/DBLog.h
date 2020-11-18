//
//  DBLog.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, DBLogLevel) {
    DBLogLevelError = 0,
    DBLogLevelWarning,
    DBLogLevelInfo,
    DBLogLevelDebug,
    DBLogLevelVerbose
};
NS_ASSUME_NONNULL_BEGIN

@interface DBLog : NSObject

+ (void)log:(DBLogLevel)level tag:(NSString *)tag msg:(NSString *)msg;

+ (DBLogLevel)logLevelByString:(NSString *)levelStr;

@end

NS_ASSUME_NONNULL_END
