//
//  UIImage+DB.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (DBXExtends)

-(UIImage *)getResizableImageWithPatchType:(NSString *)patchType;
-(UIImage*)OriginImage:(UIImage *)image scaleToSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
