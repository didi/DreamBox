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

@interface DBView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation DBView

-(void)setDataWithModel:(DBViewModel *)viewModel andPathId:(NSString *)pathId
{
    if (viewModel.radius) {
         self.layer.masksToBounds = YES;
         self.layer.cornerRadius = [viewModel.radius floatValue];
     }
     
     if (viewModel.borderWidth) {
         self.layer.borderWidth = [viewModel.borderWidth floatValue];
     }
     
     if (viewModel.borderColor) {
         self.layer.borderColor = [UIColor db_colorWithHexString:viewModel.borderColor].CGColor;
     }
     
     
     if ([viewModel.shape isEqualToString:@"circle"]) {
         self.layer.masksToBounds = YES;
         self.layer.cornerRadius = self.bounds.size.height / 2.0;
     }
     
     //    #711234-#269869-#269869
     if (viewModel.gradientColor) {
         _gradientLayer  = [CAGradientLayer layer];
         NSArray *colors = [viewModel.gradientColor  componentsSeparatedByString:@"-"];
         NSMutableArray *colorsArray = [NSMutableArray array];
         for (NSString *color in  colors) {
             [colorsArray addObject:(__bridge id)[UIColor db_colorWithHexString:color].CGColor];
         }
         _gradientLayer.colors = colorsArray;
         
         if ([viewModel.gradientOrientation isEqualToString:@"horizontal"]) {
             _gradientLayer.startPoint = CGPointMake(0, 0);
             _gradientLayer.endPoint = CGPointMake(1.0, 0);
         }else{
             _gradientLayer.startPoint = CGPointMake(0, 0);
             _gradientLayer.endPoint = CGPointMake(0,1.0);
         }
         [self.layer addSublayer:_gradientLayer];
     }
     
     _gradientLayer.frame = self.bounds;
    
    //回调给外面，进行组件的渲染
//    if(viewModel.children.count > 0){
//        []
//    }
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.gradientLayer.frame = self.bounds;
}

-(CGSize)wrapSize {
    return CGSizeZero;
}
@end
