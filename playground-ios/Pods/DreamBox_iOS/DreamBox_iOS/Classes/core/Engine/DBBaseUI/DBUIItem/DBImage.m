//
//  DBImage.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBImage.h"
#import "DBViewProtocol.h"
#import "DBParser.h"
#import "DBHelper.h"
#import "DBWrapperManager.h"
#import "DBPool.h"
#import "DBImageLoader.h"
#import "Masonry.h"

@implementation DBImage {
    UIImageView * _imageView;
}

#pragma mark - lideCycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [UIImageView new];
        [self addSubview:_imageView];
        
    }
    return self;
}

#pragma mark - DBViewProtocol
-(void)setDataWithModel:(DBImageModel *)imageModel andPathId:(NSString *)pathId{
    [super setDataWithModel:imageModel andPathId:pathId];
    if(imageModel.src){
        [self handleChangeOn:imageModel.changeOn];
    }
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.mas_equalTo(self);
    }];
        
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    if ([imageModel.scaleType isEqualToString:@"crop"]) {
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    if ([imageModel.scaleType isEqualToString:@"inside"]) {
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
     }
    if ([imageModel.scaleType isEqualToString:@"fitXY"]) {
        _imageView.contentMode = UIViewContentModeScaleToFill;
    }
    
    [self refreshImage];
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
    DBImageModel *imageModel = (DBImageModel *)self.model;
    NSString *src = [DBParser getRealValueByPathId:self.pathId andKey:imageModel.src];
    NSString *accessKey = [[DBPool shareDBPool] getAccessKeyWithPathId:self.pathId];
    if ([DBValidJudge isValidString:src]) {
        [[DBWrapperManager sharedManager] imageLoadService:_imageView accessKey:accessKey setImageUrl:src];
    }
}

@end
