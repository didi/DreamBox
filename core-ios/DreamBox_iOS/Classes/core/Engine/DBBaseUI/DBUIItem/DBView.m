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
    
    if(_viewModel.radius) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = [_viewModel.radius floatValue];
    }
    
    if(_viewModel.radiusLT
       || _viewModel.radiusRT
       || _viewModel.radiusLB
       || _viewModel.radiusRB){
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        shapeLayer.path = [self cornerShapeWithRect:self.bounds
                                           cornerLT:[DBDefines db_getUnit:_viewModel.radiusLT]
                                           cornerRT:[DBDefines db_getUnit:_viewModel.radiusRT]
                                           cornerLB:[DBDefines db_getUnit:_viewModel.radiusLB]
                                           cornerRB:[DBDefines db_getUnit:_viewModel.radiusRB]
                           ];
        self.layer.mask = shapeLayer;
    }
    
    self.gradientLayer.frame = self.bounds;
}


- (CGPathRef)cornerShapeWithRect:(CGRect)bounds
                        cornerLT:(CGFloat)cornerLT
                        cornerRT:(CGFloat)cornerRT
                        cornerLB:(CGFloat)cornerLB
                        cornerRB:(CGFloat)cornerRB
{
     const CGFloat minX = CGRectGetMinX(bounds);
     const CGFloat minY = CGRectGetMinY(bounds);
     const CGFloat maxX = CGRectGetMaxX(bounds);
     const CGFloat maxY = CGRectGetMaxY(bounds);
     
     const CGFloat topLeftCenterX = minX + cornerLT;
     const CGFloat topLeftCenterY = minY + cornerLT;
     
     const CGFloat topRightCenterX = maxX - cornerRT;
     const CGFloat topRightCenterY = minY + cornerRT;
     
     const CGFloat bottomLeftCenterX = minX + cornerLB;
     const CGFloat bottomLeftCenterY = maxY - cornerLB;
     
     const CGFloat bottomRightCenterX = maxX - cornerRB;
     const CGFloat bottomRightCenterY = maxY - cornerRB;
     //虽然顺时针参数是YES，在iOS中的UIView中，这里实际是逆时针
    
     CGMutablePathRef path = CGPathCreateMutable();
     //顶 左
     CGPathAddArc(path, NULL, topLeftCenterX, topLeftCenterY,cornerLT, M_PI, 3 * M_PI_2, NO);
     //顶 右
     CGPathAddArc(path, NULL, topRightCenterX , topRightCenterY, cornerRT, 3 * M_PI_2, 0, NO);
     //底 右
     CGPathAddArc(path, NULL, bottomRightCenterX, bottomRightCenterY, cornerRB,0, M_PI_2, NO);
     //底 左
     CGPathAddArc(path, NULL, bottomLeftCenterX, bottomLeftCenterY, cornerLB, M_PI_2,M_PI, NO);
     CGPathCloseSubpath(path);
     return path;
}

-(CGSize)wrapSize {
    return CGSizeZero;
}
@end
