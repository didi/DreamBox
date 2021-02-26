//
//  DBImage.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXImage.h"
#import "DBXViewProtocol.h"
#import "DBXParser.h"
#import "DBXHelper.h"
#import "DBXWrapperManager.h"
#import "DBXPool.h"
#import "DBXImageLoader.h"
#import <Masonry/Masonry.h>
#import "UIImage+DBXExtends.h"

@interface DBXImage()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) DBXImageModel *imageModel;
@end

@implementation DBXImage

#pragma mark - DBXViewProtocol
- (void)onCreateView{
    [super onCreateView];
    
    _imageView = [UIImageView new];
    [self addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.mas_equalTo(self);
    }];
}

- (void)onAttributesBind:(DBXViewModel *)attributesModel{
    [super onAttributesBind:attributesModel];
    _imageModel = (DBXImageModel *)attributesModel;
    
    if(_imageModel.src){
        [self handleChangeOn:_imageModel.changeOn];
    }
    
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    if ([_imageModel.scaleType isEqualToString:@"crop"]) {
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    if ([_imageModel.scaleType isEqualToString:@"inside"]) {
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
     }
    if ([_imageModel.scaleType isEqualToString:@"fitXY"]) {
        _imageView.contentMode = UIViewContentModeScaleToFill;
    }

    [self refreshImage];
#if DEBUG
    if([self.imageModel.backgroundColor isEqualToString:@"#000F0F"]){
        
    }
#endif
}

- (CGSize)wrapSize {
    [_imageView sizeToFit];
    return _imageView.frame.size;
}

#pragma mark - inherited
- (void)reload {
    [self refreshImage];
}

#pragma mark - privateMethods
- (void)refreshImage {
    NSString *src = [DBXParser getRealValueByPathId:self.pathId andKey:_imageModel.src];
    NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:self.pathId];
    if ([DBXValidJudge isValidString:src]) {
        __weak typeof(self) weakSelf = self;
        [[DBXWrapperManager sharedManager] imageLoadService:weakSelf.imageView accessKey:accessKey setImageUrl:src callback:^(UIImage * _Nonnull image) {
            if(image){
                if([weakSelf.imageModel.srcType isEqualToString:@"ninePatch"]){
                    UIImage *image = [weakSelf.imageView.image getResizableImageWithPatchType:@""];
                    image = [image OriginImage:image scaleToSize:CGSizeMake(weakSelf.frame.size.width, weakSelf.frame.size.height)];
                    weakSelf.imageView.image = image;
                } else {
                    weakSelf.imageView.image = image;
                }
            }
        }];
    }
}

@end
