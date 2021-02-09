//
//  DBXService.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXService.h"
#import "DBXHelper.h"
#import "DBXWrapperManager.h"

@interface DBXService ()

@property (nonatomic, strong) NSMutableDictionary *dependOnDict;
@property (nonatomic, strong) NSMutableDictionary *pool;//公共pool池
@property (nonatomic, copy, readwrite) NSString *uuid;

@end

@implementation DBXService

+(instancetype)shareDBService
{
    static DBXService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service =  [[DBXService alloc] init];
    });
    return service;
}
#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        _pool = [[NSMutableDictionary alloc] init];
        _dbPool = [DBXPool shareDBPool];
        _uuid = [DBXDefines uuidString];
    }
    return self;
}

#pragma mark -
- (void)registerAccessKey:(NSString *)accessKey {
    if (![[DBXService shareDBService].pool db_hasKey:accessKey]) {
        NSMutableDictionary *channelPool = [NSMutableDictionary dictionary];
        [[DBXService shareDBService].pool db_setValue:channelPool forKey:accessKey];
    }
}
- (void)registerAccessKey:(NSString *)accessKey wrapper:(DBXWrapper *)wrapper {
    [self registerAccessKey:accessKey];
    [[DBXWrapperManager sharedManager] registerAccessKey:accessKey wrapper:wrapper];
}
- (void)setConfig:(DBXWrapperConfigModel *)config accessKey:(NSString *)accessKey {
    DBXWrapper *wrapper = [[DBXWrapperManager sharedManager] getWrapperByAccessKey:accessKey];
    if (wrapper && config) {
        wrapper.config = config;
    }
}

#pragma mark - pool
- (void)putPoolDataByAccessKey:(NSString *)accessKey dataKey:(NSString *)dataKey dataValue:(NSString *)dataValue {
    
    BOOL isValid = [DBXValidJudge isValidString:accessKey] && [DBXValidJudge isValidString:dataKey] && [DBXValidJudge isValidString:dataValue];
    if (!isValid) {
        return;
    }
    
    if ([[DBXService shareDBService].pool db_hasKey:accessKey]) {
        NSMutableDictionary *channelPool = [[DBXService shareDBService].pool objectForKey:accessKey];
        if ([DBXValidJudge isValidDictionary:channelPool]) {
            [channelPool db_setValue:dataValue forKey:dataKey];
        }
    } else {
        NSMutableDictionary *channelPool = [NSMutableDictionary dictionary];
        [channelPool db_setValue:dataValue forKey:dataKey];
        [[DBXService shareDBService].pool db_setValue:channelPool forKey:accessKey];
    }
    
}
- (NSString *)getValueByGlobalPoolKeyPath:(NSString *)keyPath {
    if (![DBXValidJudge isValidString:keyPath]) {
        return @"";
    }
    if ([[DBXService shareDBService].pool valueForKeyPath:keyPath]) {
        return [[DBXService shareDBService].pool valueForKeyPath:keyPath];
    } else {
        return @"";
    }
}
@end
