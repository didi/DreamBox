//
//  DBCCodeView.m
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/8/4.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import "DBCCodeView.h"

@interface DBCCodeView ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation DBCCodeView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubViews];

    }
    return self;
}

- (void)setUpSubViews {
    [self addSubview:self.textView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textView.frame = self.bounds;
}
#pragma mark -
- (void)bindCode:(NSString *)code {
    self.textView.text = code;
}


#pragma mark -
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
    }
    return _textView;

}

@end
