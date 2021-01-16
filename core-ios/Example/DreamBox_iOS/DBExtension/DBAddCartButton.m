//
//  DBAddCartButton.m
//  DreamBox_iOS_Example
//
//  Created by zhangchu on 2021/1/16.
//  Copyright © 2021 fangshaosheng. All rights reserved.
//

#import "DBAddCartButton.h"
#import "UIColor+DBColor.h"
#import <Masonry/Masonry.h>

#define TPL_kScal 1

@interface DBAddCartButton()

@property (nonatomic, strong) UIView *cartImageBGView;
@property (nonatomic, strong) UIImageView *cartImageView;
@property (nonatomic, strong) UIView *countLabelView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) NSInteger cartCount;

@end

@implementation DBAddCartButton

- (void)onAttributesBind:(DBViewModel *)attributesModel{
    [super onAttributesBind:attributesModel];
    [self configUI];
    self.backgroundColor = [UIColor db_colorWithHexString:attributesModel.backgroundColor];
    self.cartImageView.image = [[UIImage imageNamed:@"tpl_add_to_cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)configUI{
    [self.cartImageBGView addSubview:self.cartImageView];
    [self.countLabelView addSubview:self.countLabel];
    [self.cartImageBGView addSubview:self.countLabelView];
    [self addSubview:self.cartImageBGView];
    self.cartCount = 2;
    [self updateCountLabel];
    
    [self.cartImageBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(26);
    }];
    
    [self.cartImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.cartImageBGView.mas_centerX);
        make.centerY.mas_equalTo(self.cartImageBGView.mas_centerY);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.countLabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cartImageBGView.mas_centerX);
        make.top.mas_equalTo(self.cartImageBGView.mas_top).offset(-TPL_kScal * 2);
        make.width.height.mas_equalTo(TPL_kScal * 17);
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.countLabelView.mas_centerX);
        make.centerY.mas_equalTo(self.countLabelView.mas_centerY);
        make.width.height.mas_equalTo(TPL_kScal * 17);
    }];
}

- (void)updateCountLabel {
    if (self.cartCount > 0) {
        self.countLabelView.hidden = NO;
        self.countLabel.text = [@(self.cartCount) stringValue];
    } else {
        self.countLabelView.hidden = YES;
    }
}

- (UIView *)cartImageBGView {
    if (!_cartImageBGView) {
        _cartImageBGView = [[UIView alloc] init];
        _cartImageBGView.backgroundColor = [UIColor db_colorWithHexString:@"FF3800"];
        _cartImageBGView.layer.cornerRadius = 13;
    }
    return _cartImageBGView;
}

- (UIImageView *)cartImageView {
    if (!_cartImageView) {
        _cartImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.tintColor = [UIColor whiteColor];
            imageView;
        });
    }
    return _cartImageView;
}

- (UIView *)countLabelView {
    if (!_countLabelView) {
        _countLabelView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.cornerRadius = 8.5;
            view.layer.borderColor = [UIColor db_colorWithHexString:@"FF5626"].CGColor;
            view.layer.borderWidth = 1;
            view.hidden = YES;
            view;
        });
    }
    return _countLabelView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = ({
            UILabel *lable = [[UILabel alloc] init];
            lable.textColor = [UIColor db_colorWithHexString:@"FF5626"];
            lable.textAlignment = NSTextAlignmentCenter;
            lable.font = [UIFont systemFontOfSize: 11];
            lable.text = @"";
            lable;
        });
    }
    return _countLabel;
}


@end
