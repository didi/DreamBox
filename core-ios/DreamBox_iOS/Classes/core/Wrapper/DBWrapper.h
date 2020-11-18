//
//  DBWrapper.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/19.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DBWrapperConfigModel;
NS_ASSUME_NONNULL_BEGIN
@protocol DBWrapperProtocl <NSObject>

@optional
// override me
-(void)logService:(NSDictionary *)paraDict;
-(void)netService:(NSDictionary *)paraDict successBlock:(void(^)(id data))success failureBlock:(void(^)(NSError *error))failure;
-(void)traceService:(NSDictionary *)paraDict;
-(void)navService:(NSDictionary *)paraDict;
-(void)storageService:(NSDictionary *)paraDict callback:(void(^)(NSDictionary *dict))callback;
-(void)dialogService:(NSDictionary *)paraDict positiveBlock:(void(^)(void))positive negativeBlock:(void(^)(void))negative;
-(void)toastService:(NSDictionary *)paraDict;
-(void)getDataByTemplateId:(NSString *)tid completionBlock:(void(^)(NSError * _Nullable error,NSString *_Nullable data))completionBlock;
- (void)reportKey:(NSString *)key params:(NSDictionary<NSString * ,NSString *>*)params;
- (void)imageLoadService:(UIImageView *)imgView setImageUrl:(NSString *)urlStr callback:(void(^)(UIImage *image))block;
@end

@interface DBWrapper : NSObject <DBWrapperProtocl>

// default
- (void)default_getDataByTemplateId:(NSString *)tid completionBlock:(void (^)(NSError * _Nullable error, NSString * _Nullable data))completionBlock;

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, strong) DBWrapperConfigModel *config;
@property (nonatomic, strong) NSBundle *bundle;//获取default 的bundle
@property (nonatomic, copy) NSString *directoryPath;//路径

@end

NS_ASSUME_NONNULL_END
