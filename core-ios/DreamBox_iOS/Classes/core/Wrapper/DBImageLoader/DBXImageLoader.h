//
//  DBImage.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface DBXImageLoader : NSObject

+(DBXImageLoader *)sharedImageLoader;

+ (void)imageView:(UIImageView *)imgView setImageUrl:(NSString *)urlStr;

+ (void)imageView:(UIImageView *)imgView setImageUrl:(NSString *)urlStr callback:(void(^)(UIImage *image))block;

-(void)db_imageView:(UIImageView *)imgView placeHolder:(UIImage *)img imageUrl:(NSString *)urlStr;
@end

NS_ASSUME_NONNULL_END
