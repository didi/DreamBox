//
//  DBView.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/20.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBView.h"
#import "UIColor+DBColor.h"
#import "DBTreeView.h"
#import "DBDefines.h"

@interface DBView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) DBViewModel *viewModel;

@end

@implementation DBView

-(void)onCreateView{
    [super onCreateView];
}

-(void)onAttributesBind:(DBViewModel *)attributesModel{
    [super onAttributesBind:attributesModel];
    _viewModel = attributesModel;
     
     if (_viewModel.borderWidth) {
         self.layer.borderWidth = [_viewModel.borderWidth floatValue];
     }
     
     if (_viewModel.borderColor) {
         self.layer.borderColor = [UIColor db_colorWithHexString:_viewModel.borderColor].CGColor;
     }
     
    
   
     if ([_viewModel.shape isEqualToString:@"circle"]) {
         self.layer.masksToBounds = YES;
         self.layer.cornerRadius = self.bounds.size.height / 2.0;
     }
     
     //    #711234-#269869-#269869
     if (_viewModel.gradientColor) {
         _gradientLayer  = [CAGradientLayer layer];
         NSArray *colors = [_viewModel.gradientColor  componentsSeparatedByString:@"-"];
         NSMutableArray *colorsArray = [NSMutableArray array];
         for (NSString *color in  colors) {
             [colorsArray addObject:(__bridge id)[UIColor db_colorWithHexString:color].CGColor];
         }
         _gradientLayer.colors = colorsArray;
         
         if ([_viewModel.gradientOrientation isEqualToString:@"horizontal"]) {
             _gradientLayer.startPoint = CGPointMake(0, 0);
             _gradientLayer.endPoint = CGPointMake(1.0, 0);
         }else{
             _gradientLayer.startPoint = CGPointMake(0, 0);
             _gradientLayer.endPoint = CGPointMake(0,1.0);
         }
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
