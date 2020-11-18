//
//  DBProgress.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBProgress.h"
#import "DBImageLoader.h"
#import "DBParser.h"

@interface DBProgress()

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) UIImageView *barBg;
@property (nonatomic, strong) UIImageView *barFg;
@property (nonatomic, copy) NSString *direction;

@end

@implementation DBProgress

-(void)setDataWithModel:(DBProgressModel *)progressModel andPathId:(NSString *)pathId{
//    self.direction = progressModel.direction;
    [super setDataWithModel:progressModel andPathId:pathId];
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _barBg = [[UIImageView alloc] init];
        _barFg = [[UIImageView alloc] init];
        [self addSubview:_barBg];
        [self addSubview:_barFg];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}

-(void)layoutSubviews{
    DBProgressModel *model = (DBProgressModel *)self.model;
    
    NSString *bgUrl = [DBParser getRealValueByPathId:self.pathId andKey:model.barBg];
    [DBImageLoader imageView:self.barBg setImageUrl:bgUrl callback:^(UIImage * _Nonnull image) {
        UIImage *bgImage = [self getResizableImage:image];
        self.barBg.image = bgImage;
        if(bgImage.size.height*1.0 > 0){
            self.barBg.transform = CGAffineTransformMakeScale(1, self.bounds.size.height/bgImage.size.height*1.0);
        }
    }];

    NSString *fgUrl = [DBParser getRealValueByPathId:self.pathId andKey:model.barFg];
    [DBImageLoader imageView:self.barFg setImageUrl:fgUrl callback:^(UIImage * _Nonnull image) {
        UIImage *fgImage = [self getResizableImage:image];
        self.barFg.image = fgImage;
        if(fgImage.size.height*1.0 > 0){
            self.barFg.transform = CGAffineTransformMakeScale(1, self.bounds.size.height/fgImage.size.height*1.0);
        }
    }];
    
    self.barBg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGFloat width = (model.value.integerValue / 100.0) * self.bounds.size.width;
    self.barFg.frame = CGRectMake(0, 0, width, self.frame.size.height);
    
//    if ([self.direction isEqualToString:@"vertical"]) {
//        CGFloat height = (model.value.integerValue / 100.0) * self.bounds.size.height;
//        self.barFg.frame = CGRectMake(0,  self.bounds.size.height - height, self.bounds.size.width,height);
//    }else{
//        CGFloat width = (model.value.integerValue / 100.0) * self.bounds.size.width;
//        self.barFg.frame = CGRectMake(0, 0, width, self.bounds.size.height);
//    }
    
    self.barBg.contentMode = UIViewContentModeScaleToFill;
    self.barFg.contentMode = UIViewContentModeScaleToFill;
}


-(UIImage *)getResizableImage:(UIImage *)image {
    DBProgressModel *model = (DBProgressModel *)self.model;
    UIEdgeInsets insets = [self getresizableImageEdgeInsets:image];
    UIImage *imageCut = [self cutimageFromImage:image inRect:CGRectMake(1, 1, image.size.width, image.size.height)];
    UIEdgeInsets insetsCut = UIEdgeInsetsMake(insets.top-1, insets.left-1, insets.top, insets.right);
    if([model.patchType isEqualToString:@"repeat"]){
        image = [imageCut resizableImageWithCapInsets:insetsCut resizingMode:UIImageResizingModeTile];
    } else {
        image = [imageCut resizableImageWithCapInsets:insetsCut resizingMode:UIImageResizingModeStretch];
    }
    return image;
}

-(CGRect)getImageSize:(UIImage *)image {
    CGImageRef inImage = image.CGImage;
    CGContextRef cgctx = [self.class createARGBBitmapContextFromImage:inImage];
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    return rect;
}

-(UIImage*)OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;   //返回的就是已经改变的图片
}

- (UIEdgeInsets) getresizableImageEdgeInsets:(UIImage *)image{
    int startX = -1;
    int startY = -1;
    int endY = 0;
    int endX = 0;
    UIColor* color = nil;
    CGImageRef inImage = image.CGImage;
    CGContextRef cgctx = [self.class createARGBBitmapContextFromImage:inImage];
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    CGContextDrawImage(cgctx, rect, inImage);
    unsigned char* data = CGBitmapContextGetData(cgctx);
    //遍历y黑色像素的距离
    if (data != NULL) {
        for (int i = 0; i < h; i ++) {
            int offset = 4*w*i;
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            if (red == 0 && green== 0 && blue == 0 && alpha == 255) {
                if (startY == -1) {
                    startY = i;
                }
                endY = i;
            }
        }
    }
    //遍历x黑色像素的距离
    if (data != NULL) {
        for (int i = 0; i < w; i ++) {
            int offset = 4*i;
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            if (red == 0 && green == 0 && blue == 0 && alpha == 255) {
                if (startX == -1) {
                    startX = i;
                }
                endX = i;
            }
        }
    }
    
    CGContextRelease(cgctx);
    if (data) { free(data); }
    return UIEdgeInsetsMake(startY, startX ,  startY, startX);
}

- (UIColor *) getPixelColorAtLocation:(CGPoint)point andImage:(UIImage *)image{
    UIColor* color = nil;
    CGImageRef inImage = image.CGImage;
    CGContextRef cgctx = [self.class createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) {
        return nil; /* error */
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    CGContextDrawImage(cgctx, rect, inImage);
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    CGContextRelease(cgctx);
    if (data) { free(data); }
    return color;
}

- (UIImage *)cutimageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGRect rect2 = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    CGImageRef cgImg = CGImageCreateWithImageInRect(image.CGImage, rect2);
    UIImage *clippedImg = [UIImage imageWithCGImage:cgImg];
    CGImageRelease(cgImg);
    return clippedImg;
}

-(CGSize)wrapSize {
    return CGSizeZero;
}

+ (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    bitmapData = malloc( bitmapByteCount );
    
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    CGColorSpaceRelease( colorSpace );
    return context;
}

@end
