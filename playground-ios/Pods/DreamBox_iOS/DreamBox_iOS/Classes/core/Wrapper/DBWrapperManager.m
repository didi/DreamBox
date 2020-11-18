//
//  DBWrapperManager.m
//  DreamBox_iOS
//
//  Created by fangshaosheng on 2020/6/24.
//

#import "DBWrapperManager.h"
#import "DBDefaultWrapper.h"
#import "DBHelper.h"

@interface DBWrapperManager ()
@property (nonatomic, strong) DBDefaultWrapper *defaultWrapper;
@property (nonatomic, strong) NSMutableDictionary *wrapperPool;//wrapper池
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSMutableDictionary *> *reportOnceDict;//wrapper池
@end

@implementation DBWrapperManager

+ (instancetype)sharedManager {
    static DBWrapperManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager =  [[DBWrapperManager alloc] init];
    });
    return manager;
}
#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        _defaultWrapper = [[DBDefaultWrapper alloc] init];
        _defaultWrapper.accessKey = @"DBInnerDefault";
        _wrapperPool = [[NSMutableDictionary alloc] init];
        _reportOnceDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerAccessKey:(NSString *)accessKey wrapper:(DBWrapper *)wrapper {

    if (wrapper && [wrapper isKindOfClass:DBWrapper.class]) {
        wrapper.accessKey = accessKey;
        [self p_defaultsettingWrapper:wrapper];
        [self.wrapperPool db_setValue:wrapper forKey:accessKey];
    }
}
- (DBWrapper *)getWrapperByAccessKey:(NSString *)accessKey {
    return [self p_getWrapperByAccessKey:accessKey];
}
#pragma mark -
- (DBWrapper *)p_getWrapperByAccessKey:(NSString *)accessKey {
    if ([DBValidJudge isValidString:accessKey] && [self.wrapperPool db_hasKey:accessKey]) {
        return [self.wrapperPool objectForKey:accessKey];
    } else {
        return nil;
    }
}

- (void)getDataByTemplateId:(NSString *)tid accessKey:(NSString *)accessKey completionBlock:(DBWrapperCompletionBlock)completionBlock {
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (wrapper && [wrapper respondsToSelector:@selector(getDataByTemplateId:completionBlock:)]) {
        [wrapper getDataByTemplateId:tid completionBlock:^(NSError * _Nonnull error, NSString * _Nonnull data) {
            
            if (error || !data) {
                [wrapper default_getDataByTemplateId:tid completionBlock:^(NSError * _Nullable error, NSString * _Nullable data) {
                    if (completionBlock) {
                        completionBlock(error,data);
                    }
                }];
            } else {
                if (completionBlock) {
                    completionBlock(error,data);
                }
            }
        }];
    } else {
        if (!wrapper) {
            wrapper = [[DBWrapper alloc] init];
        }
        
        [wrapper default_getDataByTemplateId:tid completionBlock:^(NSError * _Nullable error, NSString * _Nullable data) {
                        
            if (completionBlock) {
                completionBlock(error,data);
            }
        }];
    }
}
#pragma mark -
-(void)logService:(id)paraDict accessKey:(nonnull NSString *)accessKey
{
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (wrapper && [wrapper respondsToSelector:@selector(logService:)]) {
        [wrapper logService:paraDict];
    } else {
        [self.defaultWrapper logService:paraDict];
    }
}
-(void)traceService:(id)paraDict accessKey:(nonnull NSString *)accessKey
{
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (wrapper && [wrapper respondsToSelector:@selector(traceService:)]) {
        [wrapper traceService:paraDict];
    } else {
        [self.defaultWrapper traceService:paraDict];
    }
}
-(void)storageService:(id)paraDict accessKey:(nonnull NSString *)accessKey callback:(nonnull void (^)(NSDictionary * _Nonnull))callback
{
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (wrapper && [wrapper respondsToSelector:@selector(storageService:callback:)]) {
        [wrapper storageService:paraDict callback:^(NSDictionary * _Nonnull dict) {
            if (callback) {
                callback(dict);
            }
        }];
    } else {
        [self.defaultWrapper storageService:paraDict callback:^(NSDictionary * _Nonnull dict) {
            if (callback) {
                callback(dict);
            }
        }];
    }
}
-(void)toastService:(id)paraDict accessKey:(nonnull NSString *)accessKey
{
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (wrapper && [wrapper respondsToSelector:@selector(toastService:)]) {
        [wrapper toastService:paraDict];
    } else {
        [self.defaultWrapper toastService:paraDict];
    }
}

-(void)netService:(id)paraDict accessKey:(nonnull NSString *)accessKey successBlock:(DBWrapperSuccessBlock)successBlock failureBlock:(DBWrapperFailureBlock)failureBlock
{
   
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (wrapper && [wrapper respondsToSelector:@selector(netService:successBlock:failureBlock:)]) {
        [wrapper netService:paraDict successBlock:successBlock failureBlock:failureBlock];
    } else {
        [self.defaultWrapper netService:paraDict successBlock:successBlock failureBlock:failureBlock];
    }
}

- (void)navService:(id)paraDict accessKey:(nonnull NSString *)accessKey successBlock:(void (^)(void))successBlock failureBlock:(void (^)(void))failureBlock
{
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (wrapper && [wrapper respondsToSelector:@selector(navService:)]) {
        [wrapper navService:paraDict];
    } else {
        [self.defaultWrapper navService:paraDict];
    }
}

- (void)dialogService:(id)paraDict accessKey:(nonnull NSString *)accessKey positiveBlock:(void (^)(void))positive negativeBlock:(void (^)(void))negative {
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (wrapper && [wrapper respondsToSelector:@selector(dialogService:positiveBlock:negativeBlock:)]) {
        [wrapper dialogService:paraDict positiveBlock:positive negativeBlock:negative];
    } else {
        [self.defaultWrapper dialogService:paraDict positiveBlock:positive negativeBlock:negative];
    }
}
- (void)imageLoadService:(UIImageView *)imgView accessKey:(nonnull NSString *)accessKey setImageUrl:(NSString *)urlStr {
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (wrapper && [wrapper respondsToSelector:@selector(imageLoadService:setImageUrl:)]) {
        [wrapper imageLoadService:imgView setImageUrl:urlStr];
    } else {
        [self.defaultWrapper imageLoadService:imgView setImageUrl:urlStr];
    }
}

- (void)reportTid:(NSString *)tid Key:(NSString *)key accessKey:(nonnull NSString *)accessKey params:(NSDictionary<NSString * ,NSString *>*)params frequency:(DBReportFrequency)frequency {
    
    DBWrapper *wrapper = [self p_getWrapperByAccessKey:accessKey];
    if (![self p_canReport:wrapper]) {
        return;
    }
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:params];
    if (!wrapper) {
        // 拼接公参数
        [tempDict db_setValue:self.defaultWrapper.uuid forKey:@"uuid"];
        
        [tempDict db_setValue:self.defaultWrapper.accessKey forKey:@"access_key"];
        [tempDict db_setValue:[tid db_MD5ForLower32Bate] forKey:@"template_id"];
    } else {
        [tempDict db_setValue:wrapper.uuid forKey:@"uuid"];
        [tempDict db_setValue:wrapper.accessKey forKey:@"access_key"];
        [tempDict db_setValue:[tid db_MD5ForLower32Bate] forKey:@"template_id"];
    }
    
    [tempDict db_setValue:[DBDefines db_report_version] forKey:@"version"];
    
#if DEBUG
    [tempDict db_setValue:@"1" forKey:@"debug"];
#else
    [tempDict db_setValue:@"0" forKey:@"debug"];
#endif
    
    params = tempDict;
    
    
    switch (frequency) {
        case DBReportFrequencyONCE:
            
            if ([self.reportOnceDict db_hasKey:tid]) {
                NSMutableDictionary *dict = [self.reportOnceDict objectForKey:tid];
                if ([dict db_hasKey:key]) {
                    return;
                } else {
                    [dict db_setValue:@"1" forKey:key];
                }
            } else {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [self.reportOnceDict db_setValue:dict forKey:tid];
            }
            
            break;
        case DBReportFrequencySAMPLE:
            
            if (![self p_canFrequencyReport:wrapper]) {
                return;
            }
            
            break;
        case DBReportFrequencyEVERY:
                
            break;
        default:
            break;
    }
    
    if (wrapper && [wrapper respondsToSelector:@selector(reportKey:params:)]) {
        [wrapper reportKey:key params:params];
    } else {
        [self.defaultWrapper reportKey:key params:params];
    }
}

#pragma mark -
- (BOOL)p_canReport:(DBWrapper *)wrapper {
    if (!wrapper.config) {
        return YES;// 默认YES
    } else {
        return wrapper.config.isReport;
    }
}
- (BOOL)p_canFrequencyReport:(DBWrapper *)wrapper {
    if (!wrapper.config) {
        return YES;// 默认YES
    } else {
        if (!wrapper.config.isReport) {
            return NO;
        } else {
            float frequency = (float)(arc4random()%100) / 100;
            if (frequency > (1 - wrapper.config.sampleFrequency) ) {
                return YES;
            } else {
                return NO;
            }
        }
    }
}
- (void)p_defaultsettingWrapper:(DBWrapper *)wrapper {
    wrapper.uuid = [DBDefines uuidString];
    wrapper.version = [DBDefines db_version];
}


@end
