//
//  DBService.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBService.h"
#import "DBHelper.h"
#import "DBWrapperManager.h"

@interface DBService ()

@property (nonatomic, strong) NSMutableDictionary *dependOnDict;
@property (nonatomic, strong) NSMutableDictionary *pool;//公共pool池
@property (nonatomic, copy, readwrite) NSString *uuid;

@end

@implementation DBService

+(instancetype)shareDBService
{
    static DBService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service =  [[DBService alloc] init];
    });
    return service;
}
#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        _pool = [[NSMutableDictionary alloc] init];
        _dbPool = [DBPool shareDBPool];
        _uuid = [DBDefines uuidString];
    }
    return self;
}

#pragma mark -
- (void)registerAccessKey:(NSString *)accessKey {
    if (![[DBService shareDBService].pool db_hasKey:accessKey]) {
        NSMutableDictionary *channelPool = [NSMutableDictionary dictionary];
        [[DBService shareDBService].pool db_setValue:channelPool forKey:accessKey];
    }
}
- (void)registerAccessKey:(NSString *)accessKey wrapper:(DBWrapper *)wrapper {
    [self registerAccessKey:accessKey];
    [[DBWrapperManager sharedManager] registerAccessKey:accessKey wrapper:wrapper];
}
- (void)setConfig:(DBWrapperConfigModel *)config accessKey:(NSString *)accessKey {
    DBWrapper *wrapper = [[DBWrapperManager sharedManager] getWrapperByAccessKey:accessKey];
    if (wrapper && config) {
        wrapper.config = config;
    }
}

#pragma mark - pool
- (void)putPoolDataByAccessKey:(NSString *)accessKey dataKey:(NSString *)dataKey dataValue:(NSString *)dataValue {
    
    BOOL isValid = [DBValidJudge isValidString:accessKey] && [DBValidJudge isValidString:dataKey] && [DBValidJudge isValidString:dataValue];
    if (!isValid) {
        return;
    }
    
    if ([[DBService shareDBService].pool db_hasKey:accessKey]) {
        NSMutableDictionary *channelPool = [[DBService shareDBService].pool objectForKey:accessKey];
        if ([DBValidJudge isValidDictionary:channelPool]) {
            [channelPool db_setValue:dataValue forKey:dataKey];
        }
    } else {
        NSMutableDictionary *channelPool = [NSMutableDictionary dictionary];
        [channelPool db_setValue:dataValue forKey:dataKey];
        [[DBService shareDBService].pool db_setValue:channelPool forKey:accessKey];
    }
    
}
- (NSString *)getValueByGlobalPoolKeyPath:(NSString *)keyPath {
    if (![DBValidJudge isValidString:keyPath]) {
        return @"";
    }
    if ([[DBService shareDBService].pool valueForKeyPath:keyPath]) {
        return [[DBService shareDBService].pool valueForKeyPath:keyPath];
    } else {
        return @"";
    }
}
@end
