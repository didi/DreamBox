//
//  DBFrameLayout.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import "DBFrameLayout.h"
#import "DBDefines.h"

@implementation DBFrameLayout

+ (UIEdgeInsets)contentRectEdgewithModel:(DBFrameModel *)model {
    CGFloat left = 0;
    CGFloat top = 0;
    CGFloat right = 0;
    CGFloat bottom = 0;
    
    CGFloat padding = [DBDefines db_getUnit:model.padding];
    if(padding > 0){
        left = padding;
        top = padding;
        right = padding;
        bottom = padding;
    }
    
    CGFloat paddingLeft = [DBDefines db_getUnit:model.paddingLeft];
    if(paddingLeft > 0){
        left = paddingLeft;
    }

    CGFloat paddingRight = [DBDefines db_getUnit:model.paddingRight];
    if(paddingLeft > 0){
        right = paddingRight;
    }

    CGFloat paddingTop = [DBDefines db_getUnit:model.paddingTop];
    if(paddingTop > 0){
       top = paddingTop;
    }

    CGFloat paddingBottom = [DBDefines db_getUnit:model.paddingBottom];
    if(paddingBottom > 0){
        bottom = paddingBottom;
    }
    
    return UIEdgeInsetsMake(top, left, bottom, right);
}

+ (void)frameLayoutWithView:(UIView *)view withModel:(DBFrameModel *)model contentSize:(CGSize)size edgeInsets:(UIEdgeInsets)edgeInsets{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = [DBDefines db_getUnit:model.width];
    CGFloat h = [DBDefines db_getUnit:model.height];
    
    CGFloat Lpadding = edgeInsets.left;
    CGFloat Rpadding = edgeInsets.right;
    CGFloat Tpadding = edgeInsets.top;
    CGFloat Bpadding = edgeInsets.bottom;
    
    if(w == 0){
        w = view.frame.size.width;
    }
    
    if(h == 0){
        h = view.frame.size.height;
    }
    
    //间距
    CGFloat ml = [DBDefines db_getUnit:model.marginLeft];
    CGFloat mt = [DBDefines db_getUnit:model.marginTop];
    CGFloat mr = [DBDefines db_getUnit:model.marginRight];
    CGFloat mb = [DBDefines db_getUnit:model.marginBottom];
    

    
    if(model.marginLeft){
        x = ml + Lpadding;
    }
    
    if(model.marginTop){
        y = mt + Tpadding;
    }
    
    if(model.marginRight){
        x = size.width - w - mr - Rpadding;
    }
    
    if(model.marginBottom){
        y = size.height - h - mb - Bpadding;
    }
    
    if([model.width isEqual:@"fill"] || [model.width isEqual:@"wrap"]){
        w = size.width - ml - mr - Lpadding - Rpadding;
    }
    
    if([model.height isEqual:@"fill"] || [model.height isEqual:@"wrap"]){
        h = size.height - mt - mb - Tpadding - Bpadding;
    }
    
    //重力
    if(model.gravity & DBFrameGravityStart){
        x = ml + Lpadding;
    }
    if(model.gravity & DBFrameGravityEnd){
        x = size.width - w - mr - Rpadding;
    }
    if(model.gravity & DBFrameGravityTop){
        y = mt + Tpadding;
    }
    if(model.gravity & DBFrameGravityBottom){
        y = size.height - h - mb - Bpadding;
    }
    
    //初步计算简单重力+间距 得到的frame
    view.frame = CGRectMake(x, y, w, h);
    
    if(model.gravity & DBFrameGravityCenter){
        view.center = CGPointMake(size.width/2+ml-mr, size.height/2+mt-mb);
    }
    
    if(model.gravity & DBFrameGravityCenterHorizental){
        view.center = CGPointMake(size.width/2+ml-mr, view.center.y);
    }
    
    if(model.gravity & DBFrameGravityCentervertical){
        view.center = CGPointMake(view.center.x, size.height/2+mt-mb);
    }
}

@end
