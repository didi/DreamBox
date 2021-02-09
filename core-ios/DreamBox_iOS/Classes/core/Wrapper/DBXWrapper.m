//
//  DBXWrapper.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/19.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXWrapper.h"
#import "DBXLog.h"
#import "DBXHelper.h"
#import "DBXDefines.h"
#import "DBXWrapperConfigModel.h"
@implementation DBXWrapper

- (instancetype)init {
    self = [super init];
    if (self) {
        _uuid = [DBXDefines uuidString];
        _version = [DBXDefines db_version];
        DBXWrapperConfigModel *config = [[DBXWrapperConfigModel alloc] init];
        config.isReport = YES;
        config.sampleFrequency = .9f;
        _config = config;
    }
    return self;
}

- (void)default_getDataByTemplateId:(NSString *)tid completionBlock:(void (^)(NSError * _Nullable error, NSString * _Nullable data))completionBlock {
    
    NSError *error;
    if (![DBXValidJudge isValidString:tid]) {
        error = [NSError errorWithDomain:@"DBRender" code:-999 userInfo:nil];
    } else {
        tid = [NSString stringWithFormat:@"local.%@",tid];
    }
    NSBundle *bundle = [NSBundle mainBundle];
    if (self.bundle) {
        bundle = self.bundle;
    }
    NSString *string = nil;
    if ([DBXValidJudge isValidString:self.directoryPath]) {
        string = [NSString stringWithContentsOfFile:[bundle pathForResource:tid ofType:@"dbt" inDirectory:self.directoryPath]  encoding:NSUTF8StringEncoding error:&error];
    } else {
        string = [NSString stringWithContentsOfFile:[bundle pathForResource:tid ofType:@"dbt"] encoding:NSUTF8StringEncoding error:&error];
    }
    
    if (completionBlock) {
        completionBlock(error,string);
    }
    
}

@end
