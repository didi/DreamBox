//
//  DBFrameLayout.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import "DBFrameLayout.h"
#import "DBDefines.h"

@implementation DBFrameLayout

+ (void)frameLayoutWithView:(UIView *)view withModel:(DBFrameModel *)model contentSize:(CGSize)size{
    CGFloat x,y,w,h;
    w = [DBDefines db_getUnit:model.width];
    h = [DBDefines db_getUnit:model.height];
    
    //间距
    CGFloat ml = [DBDefines db_getUnit:model.marginLeft];
    CGFloat mt = [DBDefines db_getUnit:model.marginTop];
    CGFloat mr = [DBDefines db_getUnit:model.marginRight];
    CGFloat mb = [DBDefines db_getUnit:model.marginBottom];
    
    if(model.marginLeft){
        x = ml;
    }
    
    if(model.marginTop){
        y = mt;
    }
    
    if(model.marginRight){
        x = size.width - w - mr;
    }
    
    if(model.marginBottom){
        y = size.height - h - mb;
    }
    
    //初步计算简单重力+间距 得到的frame
    view.frame = CGRectMake(x, y, w, h);
    
    //重力
    if(model.gravity & DBFrameGravityStart){
        x = ml;
    }
    if(model.gravity & DBFrameGravityEnd){
        x = size.width - w - mr;
    }
    if(model.gravity & DBFrameGravityTop){
        y = mt;
    }
    if(model.gravity & DBFrameGravityBottom){
        y = size.height - h - mb;
    }
    
    if(model.gravity & DBFrameGravityCenter){
        view.center = CGPointMake(size.width/2+ml-mr, size.height/2+mt-mb);
    }
    
    if(model.gravity & DBFrameGravityCenterHorizental){
        view.center = CGPointMake(size.width/2+ml-mr, view.center.y+mt-mb);
    }
    
    if(model.gravity & DBFrameGravityCentervertical){
        view.center = CGPointMake(view.center.x+ml-mr, size.height/2+mt-mb);
    }
}

@end
