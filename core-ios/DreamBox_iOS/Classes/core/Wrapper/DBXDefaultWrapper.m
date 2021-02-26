//
//  DBDefaultWrapper.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/19.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXDefaultWrapper.h"
#import "DBXLog.h"
#import "DBXNetwork.h"
#import "DBXTrace.h"
#import "DBXNav.h"
#import "DBXStorage.h"
#import "DBXDialog.h"
#import "DBXToast.h"
#import "DBXMonitor.h"
#import "DBXImageLoader.h"

#import "DBXHelper.h"
@implementation DBXDefaultWrapper
- (void)logService:(NSDictionary *)paraDict {
    
    if (![DBXValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *level = [para objectForKey:@"level"];
    NSString *tag = [para objectForKey:@"tag"];
    NSString *msg = [para objectForKey:@"msg"];
    
    DBLogLevel logLevel = DBLogLevelDebug;
    if ([DBXValidJudge isValidString:level]) {
        logLevel = [DBXLog logLevelByString:level];
    }
    if (![DBXValidJudge isValidString:tag]) {
        tag = @"";
    }
    if (![DBXValidJudge isValidString:msg]) {
        msg = @"";
    }
    
    //log
    if ([DBXValidJudge isValidString:tag] && [DBXValidJudge isValidString:msg]) {
        [DBXLog log:logLevel tag:tag msg:msg];
    }
    
}
- (void)netService:(NSDictionary *)paraDict successBlock:(void (^)(id _Nonnull data))success failureBlock:(void (^)(NSError * _Nonnull))failure {
    if (![DBXValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *url = [para objectForKey:@"url"];
    
    [DBXNetwork request:url successBlock:^(id  _Nonnull data) {
        
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
    
    if (![DBXValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *key = [para objectForKey:@"key"];
    NSDictionary *attr = [para objectForKey:@"attr"];
    
    //trace
    [DBXTrace trace:key value:attr];
}
- (void)navService:(NSDictionary *)paraDict {
    
    if (![DBXValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *schema = [para objectForKey:@"schema"];
    
    [DBXNav navigatorBySchema:schema];
}
- (void)storageService:(NSDictionary *)paraDict callback:(nonnull void (^)(NSDictionary * _Nonnull))callback{
    
    if (![DBXValidJudge isValidDictionary:paraDict]) {
        return;
    }
    
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *key = [para objectForKey:@"key"];
    
    NSString *writeValue = [para objectForKey:@"write"];
    if ([DBXValidJudge isValidString:writeValue]) {
        
        [DBXStorage setStorage:writeValue forkey:key];
        // 读写不可共存
        return ;
    }
    
    NSString *readToKey = [para objectForKey:@"readTo"];
    if ([DBXValidJudge isValidString:readToKey]) {
        
        NSString *value = [DBXStorage getStorageBykey:key];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict db_setValue:value forKey:readToKey];
        if (callback) {
            callback(dict);
        }
        return;
    }
}


- (void)dialogService:(NSDictionary *)paraDict positiveBlock:(void (^)(void))positive negativeBlock:(void (^)(void))negative {
    if (![DBXValidJudge isValidDictionary:paraDict]) {
        return;
    }
    
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *title = [para objectForKey:@"title"];
    NSString *msg = [para objectForKey:@"msg"];
    NSString *positiveBtn = [para objectForKey:@"positiveBtn"];
    NSString *negativeBtn = [para objectForKey:@"negativeBtn"];
    
    [DBXDialog showAlertViewWithTitle:title message:msg cancelButtonTitle:negativeBtn otherButtonTitle:positiveBtn cancelButtonBlock:^{
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
    
    if (![DBXValidJudge isValidDictionary:paraDict]) {
        return;
    }
    NSDictionary *para = (NSDictionary *)paraDict;
    NSString *src = [para objectForKey:@"src"];
    NSString *isLong = [para objectForKey:@"long"];
    BOOL isLongValue = NO;
    if ([DBXValidJudge isValidString:isLong]) {
        isLongValue = [isLong isEqualToString:@"1"];
    }
    [DBXToast showToast:src longTime:isLongValue];
}

- (void)reportKey:(NSString *)key params:(NSDictionary<NSString * ,NSString *>*)params {

    [DBXMonitor reportKey:key params:params];
}

- (void)imageLoadService:(UIImageView *)imgView setImageUrl:(NSString *)urlStr callback:(void(^)(UIImage *image))block{
    [DBXImageLoader imageView:imgView setImageUrl:urlStr callback:block];
}

@end
