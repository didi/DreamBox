//
//  DBImage.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXImageLoader.h"
#import "DBXHelper.h"
#import "SDWebImage.h"

@interface DBXImageLoader()

@property(nonatomic ,strong) NSFileManager *imageFileManager;

@end



@implementation DBXImageLoader

+(DBXImageLoader *)sharedImageLoader
{
    static DBXImageLoader *imageLoader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageLoader = [[DBXImageLoader alloc] init];
        imageLoader.imageFileManager = [[NSFileManager alloc] init];
        
    });
    return imageLoader;
}

+ (void)imageView:(UIImageView *)imgView setImageUrl:(NSString *)urlStr {
    
    if (![DBXValidJudge isValidString:urlStr]) {
        return;
    }
    [imgView sd_setImageWithURL:[NSURL URLWithString:urlStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
}

+ (void)imageView:(UIImageView *)imgView setImageUrl:(NSString *)urlStr callback:(void(^)(UIImage *image))block{
    if (![DBXValidJudge isValidString:urlStr]) {
        return;
    }
    
    UIImage *image = [UIImage imageNamed:urlStr];
    if(image){
        block(image);
        return;
    }
    
    [imgView sd_setImageWithURL:[NSURL URLWithString:urlStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (block) {
            block(image);
        }
    }];
}

-(void)db_imageView:(UIImageView *)imgView placeHolder:(UIImage *)img imageUrl:(NSString *)urlStr {
    imgView.image = img;
    if ([[NSFileManager defaultManager] fileExistsAtPath:urlStr]) {
        imgView.image = [self getImageFromFileWithURL:urlStr];
        return;
    };
    
    [self downloadImageWithURL:urlStr complete:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imgView.image = image;
        });
        [self setImageToFile:image withURL:urlStr];
    }];
    
    
}


-(void)downloadImageWithURL:(NSString *)url complete:(void(^)(UIImage *image))block
{

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error:%@",error);
        }
        
        UIImage *img = [UIImage imageWithData:data scale:1.0];
        if (!img) {
            img = [UIImage imageWithData:data scale:1.0];//jpeg
        }
        
        block(img);
    }];
    [task resume];
}


-(UIImage *)getImageFromFileWithURL:(NSString *)imageUrl
{
    NSData *data = [NSData dataWithContentsOfFile:imageUrl];
    UIImage *img = [UIImage imageWithData:data];
    if (!img) {
        img = [UIImage imageWithData:data scale:1.0];
    }
    return img;
}

- (void)setImageToFile:(UIImage *)img withURL:(NSString *)imageUrl
{
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    if (!data) {
        data = UIImagePNGRepresentation(img);
    }
    [data writeToFile:imageUrl atomically:NO];
}







@end
