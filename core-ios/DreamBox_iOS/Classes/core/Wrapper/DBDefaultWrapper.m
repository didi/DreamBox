//
//  DBDefaultWrapper.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/19.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBDefaultWrapper.h"
#import "DBLog.h"
#import "DBNetwork.h"
#import "DBTrace.h"
#import "DBNav.h"
#import "DBStorage.h"
#import "DBDialog.h"
#import "DBToast.h"
#import "DBMonitor.h"
#import "DBImageLoader.h"

#import "DBHelper.h"
@implementation DBDefaultWrapper
- (void)logService:(NSDictionary *)paraDict {
    
    if (![DBValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *level = [para objectForKey:@"level"];
    NSString *tag = [para objectForKey:@"tag"];
    NSString *msg = [para objectForKey:@"msg"];
    
    DBLogLevel logLevel = DBLogLevelDebug;
    if ([DBValidJudge isValidString:level]) {
        logLevel = [DBLog logLevelByString:level];
    }
    if (![DBValidJudge isValidString:tag]) {
        tag = @"";
    }
    if (![DBValidJudge isValidString:msg]) {
        msg = @"";
    }
    
    //log
    if ([DBValidJudge isValidString:tag] && [DBValidJudge isValidString:msg]) {
        [DBLog log:logLevel tag:tag msg:msg];
    }
    
}
- (void)netService:(NSDictionary *)paraDict successBlock:(void (^)(id _Nonnull data))success failureBlock:(void (^)(NSError * _Nonnull))failure {
    if (![DBValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *url = [para objectForKey:@"url"];
    
    [DBNetwork request:url successBlock:^(id  _Nonnull data) {
        
        if (success) {
            success(data);
        }
    } failureBlock:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)traceService:(NSDictionary *)paraDict {
    
    if (![DBValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *key = [para objectForKey:@"key"];
    NSDictionary *attr = [para objectForKey:@"attr"];
    
    //trace
    [DBTrace trace:key value:attr];
}
- (void)navService:(NSDictionary *)paraDict {
    
    if (![DBValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *schema = [para objectForKey:@"schema"];
    
    [DBNav navigatorBySchema:schema];
}
- (void)storageService:(NSDictionary *)paraDict callback:(nonnull void (^)(NSDictionary * _Nonnull))callback{
    
    if (![DBValidJudge isValidDictionary:paraDict]) {
        return;
    }
    
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *key = [para objectForKey:@"key"];
    
    NSString *writeValue = [para objectForKey:@"write"];
    if ([DBValidJudge isValidString:writeValue]) {
        
        [DBStorage setStorage:writeValue forkey:key];
        // 读写不可共存
        return ;
    }
    
    NSString *readToKey = [para objectForKey:@"readTo"];
    if ([DBValidJudge isValidString:readToKey]) {
        
        NSString *value = [DBStorage getStorageBykey:key];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict db_setValue:value forKey:readToKey];
        if (callback) {
            callback(dict);
        }
        return;
    }
}


- (void)dialogService:(NSDictionary *)paraDict positiveBlock:(void (^)(void))positive negativeBlock:(void (^)(void))negative {
    if (![DBValidJudge isValidDictionary:paraDict]) {
        return;
    }
    
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *title = [para objectForKey:@"title"];
    NSString *msg = [para objectForKey:@"msg"];
    NSString *positiveBtn = [para objectForKey:@"positiveBtn"];
    NSString *negativeBtn = [para objectForKey:@"negativeBtn"];
    
    [DBDialog showAlertViewWithTitle:title message:msg cancelButtonTitle:negativeBtn otherButtonTitle:positiveBtn cancelButtonBlock:^{
        if (negative) {
            negative();
        }
    } otherButtonBlock:^{
        if (positive) {
            positive();
        }
    }];
}

- (void)toastService:(NSDictionary *)paraDict {
    
    if (![DBValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *src = [para objectForKey:@"src"];
    NSString *isLong = [para objectForKey:@"long"];
    BOOL isLongValue = NO;
    if ([DBValidJudge isValidString:isLong]) {
        isLongValue = [isLong isEqualToString:@"1"];
    }
    [DBToast showToast:src longTime:isLongValue];
}

- (void)reportKey:(NSString *)key params:(NSDictionary<NSString * ,NSString *>*)params {

    [DBMonitor reportKey:key params:params];
}

- (void)imageLoadService:(UIImageView *)imgView setImageUrl:(NSString *)urlStr callback:(void(^)(UIImage *image))block{
    [DBImageLoader imageView:imgView setImageUrl:urlStr callback:block];
}

@end
