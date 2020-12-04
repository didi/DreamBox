//
//  UIImage+DB.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/10/19.
//

#import "UIImage+DBExtends.h"

@implementation UIImage (DBExtends)

-(UIImage *)getResizableImageWithPatchType:(NSString *)patchType{
    UIEdgeInsets insets = [self getresizableImageEdgeInsets:self];
    UIImage *imageCut = [self cutimageFromImage:self inRect:CGRectMake(1, 1, self.size.width - 2, self.size.height - 2)];
    UIEdgeInsets insetsCut = UIEdgeInsetsMake(insets.top-1, insets.left-1, insets.top, insets.right);
    UIImage *image = nil;
    if([patchType isEqualToString:@"repeat"]){
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
