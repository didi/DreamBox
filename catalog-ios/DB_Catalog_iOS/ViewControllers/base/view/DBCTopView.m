//
//  DBCTopView.m
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/8/4.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import "DBCTopView.h"

@interface DBCTopView ()

@property (nonatomic, strong) UIButton *resultButton;
@property (nonatomic, strong) UIButton *codeButton;

@end

@implementation DBCTopView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews {
    [self addSubview:self.resultButton];
    [self addSubview:self.codeButton];
    self.backgroundColor = UIColor.lightGrayColor;
}
#pragma mark -
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.resultButton.frame = CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height);
    self.codeButton.frame = CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, self.frame.size.height);
    
}
#pragma mark -
- (void)clickResultButton:(UIButton *)button {
    if (self.topSwitchClick) {
        self.topSwitchClick(DBCTopViewSelectedTypeResult);
    }
}
- (void)clickCodeButton:(UIButton *)button {
    if (self.topSwitchClick) {
        self.topSwitchClick(DBCTopViewSelectedTypeCode);
    }
}


#pragma mark -
- (UIButton *)resultButton {
    if (!_resultButton) {
        _resultButton = [[UIButton alloc] init];
        [_resultButton setTitle:@"效果" forState:UIControlStateNormal];
        [_resultButton addTarget:self action:@selector(clickResultButton:) forControlEvents:UIControlEventTouchUpInside];
        [_resultButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    }
    return _resultButton;
}
- (UIButton *)codeButton {
    if (!_codeButton) {
        _codeButton = [[UIButton alloc] init];
        [_codeButton setTitle:@"源码" forState:UIControlStateNormal];
        [_codeButton addTarget:self action:@selector(clickCodeButton:) forControlEvents:UIControlEventTouchUpInside];
        [_codeButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    }
    return _codeButton;
}


@end
