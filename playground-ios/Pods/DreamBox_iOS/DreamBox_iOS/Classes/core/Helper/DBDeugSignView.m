//
//  DBDeugSignView.m
//  DreamBox_iOS
//
//  Created by fangshaosheng on 2020/7/23.
//

#import "DBDeugSignView.h"
#import "DBHelper.h"

@interface DBDeugSignView ()

@property (nonatomic, strong) UIImageView *signIcon;

@end

@implementation DBDeugSignView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews {
    [self addSubview:self.signIcon];
    
    self.signIcon.hidden = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_switchIconShow)];
    gesture.numberOfTapsRequired = 10;
    [self addGestureRecognizer:gesture];
    self.userInteractionEnabled = NO;
}

- (void)p_switchIconShow {
    self.signIcon.hidden = !self.signIcon.hidden;
}

#pragma mark -
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.signIcon.frame = self.bounds;
}
#pragma mark -
- (void)showIcon {
    self.signIcon.hidden = NO;
}

#pragma mark -
- (UIImageView *)signIcon {
    if (!_signIcon) {
        _signIcon = [[UIImageView alloc] init];
        _signIcon.image = [self p_getImageWithBoudleName:@"DreamBox_iOS" imgName:@"dreambox_debug_icon"];
    }
    return _signIcon;

}

- (UIImage *)p_getImageWithBoudleName:(NSString *)boudleName imgName:(NSString *)imgName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:boudleName withExtension:@"bundle"];
    if (url) {
        NSBundle *targetBundle = [NSBundle bundleWithURL:url];
        UIImage *image = [UIImage imageNamed:imgName
                                inBundle:targetBundle
           compatibleWithTraitCollection:nil];
        return image;
    }
    return nil;
}


@end
