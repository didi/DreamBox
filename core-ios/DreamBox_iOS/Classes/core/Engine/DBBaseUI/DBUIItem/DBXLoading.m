//
//  DBLoading.m
//  DreamBox_iOS
//
//  Created by didi on 2020/7/5.
//

#import "DBXLoading.h"
#import "DBXValidJudge.h"
#import <Masonry/Masonry.h>
#import "NSArray+DBXExtends.h"

@interface DBXActivityLoading : UIImageView

- (void) startActivityAnimating;
- (void) stopActivityAnimating;
@end

NSString * const kActivityAnimationKey = @"activityRotating";

@interface DBXActivityLoading ()
@property (nonatomic,assign) BOOL activityAanimating;
@end

@implementation DBXActivityLoading


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage *aImage = [self getImageWithBoudleName:@"DreamBox_iOS" imgName:@"operation_loading"];
        self.image = aImage;
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, aImage.size.width, aImage.size.height);
        [self startActivityAnimating];
    }
    return self;
}

- (void)startActivityAnimating {
    
    self.hidden = NO;
    
    if (self.activityAanimating) return;
    
    self.activityAanimating = YES;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [self.layer valueForKeyPath:@"transform.rotation.z"];
    animation.toValue = @(M_PI * 2 + [animation.fromValue doubleValue]);
    animation.duration = 1;
    animation.repeatCount = FLT_MAX;
    animation.removedOnCompletion = NO;
    [self.layer addAnimation:animation forKey:kActivityAnimationKey];
}

- (void)stopActivityAnimating {
    
    self.hidden = YES;
    
    if (!self.activityAanimating) return;
    
    self.activityAanimating = NO;
    
    NSValue *value = [self.layer.presentationLayer valueForKey:@"transform"];
    
    [self.layer removeAnimationForKey:kActivityAnimationKey];
    
    if (value) {
        self.layer.transform = [value CATransform3DValue];
    }
}

- (UIImage *)getImageWithBoudleName:(NSString *)boudleName imgName:(NSString *)imgName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:boudleName withExtension:@"bundle"];
    NSBundle *targetBundle = [NSBundle bundleWithURL:url];
    UIImage *image = [UIImage imageNamed:imgName
                            inBundle:targetBundle
       compatibleWithTraitCollection:nil];
    return image;
}


@end


typedef NS_ENUM(NSInteger, DCDotLoadingViewState) {
    DCDotLoadingViewStateSuccess, // 成功
    DCDotLoadingViewStateLoading, // 加载中（默认）
    DCDotLoadingViewStateError    // 加载错误
};

@interface DBXDotLoadingView : UIView
/*!
 DCDotLoadingViewStateError 时的错误文案，如果设置了，会有一个 icon 在文字上方
 */
@property (nonatomic, copy) NSString *text;

@property (nonatomic) void(^clickBlock)(void);

- (void)startLoading;
- (void)stopLoading;

- (void)setup;


@end


@interface DBXDotLoadingView()
@property (nonatomic, strong) NSArray *loadingImages;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic) UIButton *backgroundButton;

@end

@implementation DBXDotLoadingView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.backgroundButton];

        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.animationDuration = 1;
        [self addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.width.height.mas_equalTo(self);
        }];
        [self startLoading];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_backgroundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.mas_equalTo(self);
    }];
    BOOL isLoadingState = _imageView.isAnimating;
    if ( isLoadingState ) {
        UIImage *image = [self.loadingImages lastObject];
    } else {
        if (!_textLabel.isHidden) {
            UIImage *image = [self getImageWithBoudleName:@"DreamBox_iOS" imgName:@"dialog_icn_wifi_error"];
            _imageView.image = image;
        }
    }
}

- (void)setup {
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
    _text = text;
    BOOL hasText = [DBXValidJudge isValidString:text];
    self.textLabel.hidden = !hasText;
    self.textLabel.text = self.text;
    [self.imageView stopAnimating];
    [self setNeedsLayout];
}

- (void)startLoading {
    self.textLabel.hidden = YES;
    _imageView.animationImages = self.loadingImages;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView startAnimating];
    [self setNeedsLayout];
}

- (void)stopLoading {
    [self.imageView stopAnimating];
    [self setNeedsLayout];
}

- (UIButton *)backgroundButton {
    if(!_backgroundButton) {
        _backgroundButton = [UIButton new];
        _backgroundButton.backgroundColor = [UIColor clearColor];
        [_backgroundButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundButton;
}

- (NSArray *)loadingImages {
    if (!_loadingImages) {
        NSMutableArray *images = [NSMutableArray new];
        [images db_addObject:[self getImageWithBoudleName:@"DreamBox_iOS" imgName:@"common_btn_animation_normal"]];
        [images db_addObject:[self getImageWithBoudleName:@"DreamBox_iOS" imgName:@"common_btn_animation_left"]];
        [images db_addObject:[self getImageWithBoudleName:@"DreamBox_iOS" imgName:@"common_btn_animation_middle"]];
        [images db_addObject:[self getImageWithBoudleName:@"DreamBox_iOS" imgName:@"common_btn_animation_right"]];
        _loadingImages = images.copy;
    }
    return _loadingImages;
}


//[self getImageWithBoudleName:@"DreamBox_iOS" imgName:@"operation_loading"];

- (UIImage *)getImageWithBoudleName:(NSString *)boudleName imgName:(NSString *)imgName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:boudleName withExtension:@"bundle"];
    NSBundle *targetBundle = [NSBundle bundleWithURL:url];
    UIImage *image = [UIImage imageNamed:imgName
                            inBundle:targetBundle
       compatibleWithTraitCollection:nil];
    return image;
}



- (void)buttonClicked:(UIButton *)button {
    BOOL isAnimating = self.imageView.isAnimating;
    if(!isAnimating && self.clickBlock) {
        self.clickBlock();
    }
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [super addGestureRecognizer:gestureRecognizer];
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        self.backgroundButton.enabled = NO;
    }
}

- (void)setClickBlock:(void (^)(void))clickBlock {
    _clickBlock = clickBlock;
    self.backgroundButton.enabled = YES;
}

@end



@implementation DBXLoading {
    DBXLoadingModel *_loadingModel;
}


-(void)onCreateView{
    [super onCreateView];
}

-(void)onAttributesBind:(DBXViewModel *)attributesModel{
    [super onAttributesBind:attributesModel];
    _loadingModel = attributesModel;
    
    if ([_loadingModel.style isEqualToString:@"dot"]) {
        DBXDotLoadingView *loadingView = [DBXDotLoadingView new];
        [self addSubview:loadingView];
        [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.height.mas_equalTo(self);
        }];
    }else{
        DBXActivityLoading *loadingView = [DBXActivityLoading new];
        [self addSubview:loadingView];
        [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.height.mas_equalTo(self);
        }];
    }
}

-(CGSize)wrapSize {
    return CGSizeZero;
}

@end
