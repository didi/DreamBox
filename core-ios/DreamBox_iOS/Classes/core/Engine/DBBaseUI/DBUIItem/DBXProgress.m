//
//  DBProgress.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXProgress.h"
#import "DBXImageLoader.h"
#import "DBXParser.h"
#import "UIColor+DBXColor.h"
#import "UIImage+DBXExtends.h"

@interface DBXProgress()

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) UIImageView *barBg;
@property (nonatomic, strong) UIImageView *barFg;
@property (nonatomic, copy) NSString *direction;
@property (nonatomic, strong) DBXProgressModel *progressModel;

@end

@implementation DBXProgress

-(void)onCreateView{
    [super onCreateView];
    _barBg = [[UIImageView alloc] init];
    _barFg = [[UIImageView alloc] init];
    [self addSubview:_barBg];
    [self addSubview:_barFg];
}

-(void)onAttributesBind:(DBXViewModel *)attributesModel{
    _progressModel = attributesModel;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}

-(void)layoutSubviews{
    NSString *bgUrl = [DBXParser getRealValueByPathId:self.pathId andKey:_progressModel.barBg];
    NSString *fgUrl = [DBXParser getRealValueByPathId:self.pathId andKey:_progressModel.barFg];
    if(bgUrl && fgUrl){
        [DBXImageLoader imageView:self.barBg setImageUrl:bgUrl callback:^(UIImage * _Nonnull image) {
            if(image != nil){
                UIImage *bgImage = [image getResizableImageWithPatchType:_progressModel.patchType];
                self.barBg.image = bgImage;
                if(bgImage.size.height*1.0 > 0){
                    self.barBg.transform = CGAffineTransformMakeScale(1, self.bounds.size.height/bgImage.size.height*1.0);
                }
            }
        }];

        
        [DBXImageLoader imageView:self.barFg setImageUrl:fgUrl callback:^(UIImage * _Nonnull image) {
            if(image != nil){
                UIImage *fgImage = [image getResizableImageWithPatchType:_progressModel.patchType];
                self.barFg.image = fgImage;
                if(fgImage.size.height*1.0 > 0){
                    self.barFg.transform = CGAffineTransformMakeScale(1, self.bounds.size.height/fgImage.size.height*1.0);
                }
            }
        }];
        
        self.barBg.contentMode = UIViewContentModeScaleToFill;
        self.barFg.contentMode = UIViewContentModeScaleToFill;
    }
    
    NSString *bgColor = [DBXParser getRealValueByPathId:self.pathId andKey:_progressModel.barBgColor];
    NSString *fgColor = [DBXParser getRealValueByPathId:self.pathId andKey:_progressModel.barFgColor];
    if(bgColor && fgColor){
        self.barBg.backgroundColor = [UIColor db_colorWithHexString:bgColor];
        self.barFg.backgroundColor = [UIColor db_colorWithHexString:fgColor];
    }
    
    self.barBg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGFloat width = (_progressModel.value.integerValue / 100.0) * self.bounds.size.width;
    self.barFg.frame = CGRectMake(0, 0, width, self.frame.size.height);
    
    if(_progressModel.radius.integerValue > 0){
        self.barFg.layer.cornerRadius = _progressModel.radius.integerValue;
        self.barFg.layer.masksToBounds = YES;
        self.barBg.layer.cornerRadius = _progressModel.radius.integerValue;
        self.barBg.layer.masksToBounds = YES;
    }
}

-(CGSize)wrapSize {
    return CGSizeZero;
}


@end
