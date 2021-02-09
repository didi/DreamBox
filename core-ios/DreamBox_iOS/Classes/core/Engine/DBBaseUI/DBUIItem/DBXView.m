//
//  DBView.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/20.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXView.h"
#import "UIColor+DBXColor.h"
#import "DBXTreeView.h"
#import "DBXDefines.h"

@interface DBXView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) DBXViewModel *viewModel;

@end

@implementation DBXView

-(void)onCreateView{
    [super onCreateView];
}

-(void)onAttributesBind:(DBXViewModel *)attributesModel{
    [super onAttributesBind:attributesModel];
    _viewModel = attributesModel;
     
     //    #711234-#269869-#269869
     if (_viewModel.gradientColor) {
         _gradientLayer  = [UIColor gradientLayerWithGradientColor:_viewModel.gradientColor gradientOrientation:_viewModel.gradientOrientation];
         [self.layer addSublayer:_gradientLayer];
     }
     
     _gradientLayer.frame = self.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.gradientLayer.frame = self.bounds;
}

-(CGSize)wrapSize {
    return CGSizeZero;
}
@end
