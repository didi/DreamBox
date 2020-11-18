//
//  DBPreProcess.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/14.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBPreProcess.h"
#import "DBHelper.h"
#import "DBLog.h"

static NSUInteger const kDB_MD5_INFO_LEN = 32;
static NSUInteger const kDB_CLI_VER_LEN = 0;
static NSUInteger const kDB_SDK_VER_LEN = 4;
static NSUInteger const kDB_EMPTY_INFO_LEN = 20;

@implementation DBPreProcess

+ (DBProcesssModel *)preProcess:(NSString *)data {
    
    if (![DBValidJudge isValidString:data]) {
        [DBLog log:DBLogLevelDebug tag:@"Parameter valid" msg:@"data is nil"];
        return nil;
    }
    
    NSUInteger len = kDB_MD5_INFO_LEN + kDB_CLI_VER_LEN + kDB_SDK_VER_LEN + kDB_EMPTY_INFO_LEN;
    if (data.length < len) {
        [DBLog log:DBLogLevelDebug tag:@"Parameter valid" msg:@"data is wrong"];
        return nil;
    }
    
    DBProcesssModel *process = [[DBProcesssModel alloc] init];
    
    NSUInteger md5Loc = 0;
    process.md5_info = [data substringWithRange:NSMakeRange(md5Loc, kDB_MD5_INFO_LEN)];
    
    NSUInteger verLoc = kDB_MD5_INFO_LEN;
    process.cli_ver_info = [data substringWithRange:NSMakeRange(verLoc, kDB_CLI_VER_LEN)];
    
    NSUInteger sdkLoc = kDB_MD5_INFO_LEN+kDB_CLI_VER_LEN;
    process.sdk_ver_info = [data substringWithRange:NSMakeRange(sdkLoc, kDB_SDK_VER_LEN)];
    // version校验
    if (![DBPreProcess isValidVersion:process.sdk_ver_info]) {
        [DBLog log:DBLogLevelDebug tag:@"version valid" msg:@"version check is fail"];
        return nil;
    }
    
    NSUInteger emptyLoc = kDB_MD5_INFO_LEN+kDB_CLI_VER_LEN+kDB_SDK_VER_LEN;
    process.empty_info = [data substringWithRange:NSMakeRange(emptyLoc, kDB_EMPTY_INFO_LEN)];
    
    //校验
    NSString *base64Str = [data substringFromIndex:len];
    NSString *jsonStr = [base64Str db_base64DecodedString];
    NSString *md5 = [jsonStr db_MD5ForLower32Bate];
    
    // md5校验
    if ([process.md5_info isEqualToString:md5]) {
        process.jsonDataStr = jsonStr;
        process.data = [jsonStr db_toJSONDictionary];
    } else {
        [DBLog log:DBLogLevelDebug tag:@"md5 valid" msg:@"md5 check is fail"];
        return nil;
    }
    
    return process;
    
}

+ (BOOL)isValidVersion:(NSString *)version {
    
    NSString *currentVerStr = [DBDefines db_version];
    
    NSString *dataVerStr = version;
    
    if ([DBValidJudge isValidString:currentVerStr] && [DBValidJudge isValidString:dataVerStr]) {
        
        NSInteger currentVer = currentVerStr.integerValue;
        NSInteger dataVer = dataVerStr.integerValue;
        
        return currentVer >= dataVer;
        
    }
    return NO;
}

@end
