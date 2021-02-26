//
//  DBFrameLayout.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import "DBXFrameLayout.h"
#import "DBXDefines.h"

@implementation DBXFrameLayout

+ (UIEdgeInsets)contentRectEdgewithModel:(DBXFrameModel *)model pathId:(NSString *)pathId{
    CGFloat left = 0;
    CGFloat top = 0;
    CGFloat right = 0;
    CGFloat bottom = 0;
    
    CGFloat padding = [DBXDefines db_getUnit:model.padding pathId:pathId];
    if(padding > 0){
        left = padding;
        top = padding;
        right = padding;
        bottom = padding;
    }
    
    CGFloat paddingLeft = [DBXDefines db_getUnit:model.paddingLeft pathId:pathId];
    if(paddingLeft > 0){
        left = paddingLeft;
    }

    CGFloat paddingRight = [DBXDefines db_getUnit:model.paddingRight pathId:pathId];
    if(paddingLeft > 0){
        right = paddingRight;
    }

    CGFloat paddingTop = [DBXDefines db_getUnit:model.paddingTop pathId:pathId];
    if(paddingTop > 0){
       top = paddingTop;
    }

    CGFloat paddingBottom = [DBXDefines db_getUnit:model.paddingBottom pathId:pathId];
    if(paddingBottom > 0){
        bottom = paddingBottom;
    }
    
    return UIEdgeInsetsMake(top, left, bottom, right);
}

+ (void)frameLayoutWithView:(UIView *)view withModel:(DBXFrameModel *)model contentSize:(CGSize)size edgeInsets:(UIEdgeInsets)edgeInsets pathId:(NSString *)pathId{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = [DBXDefines db_getUnit:model.width pathId:pathId];
    CGFloat h = [DBXDefines db_getUnit:model.height pathId:pathId];
    
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
    CGFloat ml = [DBXDefines db_getUnit:model.marginLeft pathId:pathId];
    CGFloat mt = [DBXDefines db_getUnit:model.marginTop pathId:pathId];
    CGFloat mr = [DBXDefines db_getUnit:model.marginRight pathId:pathId];
    CGFloat mb = [DBXDefines db_getUnit:model.marginBottom pathId:pathId];
    

    
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
