//
//  DBNetwork.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBNetwork.h"
#import "DBHelper.h"
@implementation DBNetwork

+ (void)request:(NSString *)urlStr successBlock:(DBNetSuccessBlock)successBlock failureBlock:(DBNetFailureBlock)failureBlock {
    
    if (![DBValidJudge isValidString:urlStr]) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-999 userInfo:nil];
            failureBlock(error);
        }
    }
    
    NSString *utf8String = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:utf8String];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session= [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
          
            if (error) {
                if (failureBlock) {
                    failureBlock(error);
                }
                return;
            }
            if (data) {                
                NSError *serializationError = nil;
                NSObject *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializationError];
                if (serializationError) {
                    if (failureBlock) {
                        failureBlock(serializationError);
                    }
                    return;
                }
                if (successBlock) {
                    successBlock(jsonObject);
                }
            } else {
                if (failureBlock) {
                    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-999 userInfo:nil];
                    failureBlock(error);
                }
            }
        });
    }];
    [dataTask resume];
}

@end
