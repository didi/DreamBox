//
//  DBWrapperManager.h
//  DreamBox_iOS
//
//  Created by fangshaosheng on 2020/6/24.
//

#import <Foundation/Foundation.h>
#import "DBWrapper.h"
#import "DBWrapperConfigModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^DBWrapperSuccessBlock)(id _Nullable data);
typedef void(^DBWrapperFailureBlock)(NSError * _Nullable error);
typedef void(^DBWrapperCompletionBlock)(NSError * _Nullable error,NSString * _Nullable data);
@interface DBWrapperManager : NSObject

+ (instancetype)sharedManager;

- (void)registerAccessKey:(NSString *)accessKey wrapper:(DBWrapper *)wrapper;
- (DBWrapper *)getWrapperByAccessKey:(NSString *)accessKey;


- (void)getDataByTemplateId:(NSString *)tid accessKey:(NSString *)accessKey completionBlock:(DBWrapperCompletionBlock)completionBlock;

-(void)logService:(id)paraDict accessKey:(NSString *)accessKey;
-(void)traceService:(id)paraDict accessKey:(NSString *)accessKey;
-(void)storageService:(id)paraDict accessKey:(NSString *)accessKey callback:(void(^)(NSDictionary *dict))callback;
-(void)toastService:(id)paraDict accessKey:(NSString *)accessKey;

-(void)netService:(id)paraDict accessKey:(NSString *)accessKey successBlock:(DBWrapperSuccessBlock)successBlock failureBlock:(DBWrapperFailureBlock)failureBlock;
-(void)navService:(id)paraDict accessKey:(NSString *)accessKey successBlock:(void(^)(void))successBlock failureBlock:(void(^)(void))failureBlock;
-(void)dialogService:(id)paraDict accessKey:(NSString *)accessKey positiveBlock:(void(^)(void))positive negativeBlock:(void(^)(void))negative;

- (void)reportTid:(NSString *)tid Key:(NSString *)key accessKey:(NSString *)accessKey params:(NSDictionary<NSString * ,NSString *>*)params frequency:(DBReportFrequency)frequency;
- (void)imageLoadService:(UIImageView *)imgView accessKey:(nonnull NSString *)accessKey setImageUrl:(NSString *)urlStr;
@end

NS_ASSUME_NONNULL_END
