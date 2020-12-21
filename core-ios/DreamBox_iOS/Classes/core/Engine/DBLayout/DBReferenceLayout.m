//
//  DBReferenceLayout.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/21.
//

#import "DBReferenceLayout.h"
#import "DBReferenceModel.h"
#import "DBDefines.h"
#import "DBText.h"

@implementation DBReferenceLayout

//layout布局
+ (void)layoutAllViews:(DBViewModel *)model andView:(DBView *)view andRelativeViewPool:(DBRecyclePool *)pool
{
    DBReferenceModel *referenceLayout = model.referenceLayout;
    //处理children的布局
    //宽
    if ([referenceLayout.width floatValue] != 0) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([DBDefines db_getUnit:referenceLayout.width]);
        }];
    }
    
    //高
    if ([referenceLayout.height floatValue] != 0) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([DBDefines db_getUnit:referenceLayout.height]);
        }];
    }
    
    //宽填满
    if ([referenceLayout.width isEqualToString:@"fill"]) {
        UIView *relationView = [pool getItemWithIdentifier:@"0"];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(relationView.mas_width);
        }];
    }
    
    //高填满
    if ([referenceLayout.height isEqualToString:@"fill"]) {
        UIView *relationView = [pool getItemWithIdentifier:@"0"];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(relationView.mas_height);
        }];
    }
    
    if (!referenceLayout.width || [referenceLayout.width isEqualToString:@"wrap"]) {
        CGSize size = [view wrapSize];
        if([view isKindOfClass:[DBText class]]){
            if(size.height > 0 && size.width > 0){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(size);
                }];
            }
        } else {
            if(size.width > 0){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(size.width);
                }];
            }
        }
    }
    
    if (!referenceLayout.height || [referenceLayout.height isEqualToString:@"wrap"]) {
        CGSize size = [view wrapSize];
        if([view isKindOfClass:[DBText class]]){
            if(size.height > 0 && size.width > 0){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(size);
                }];
            }
        } else {
            if(size.height > 0){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(size.height);
                }];
            }
        }
    }
    
    if((referenceLayout.leftToLeft || referenceLayout.leftToRight)
       && (referenceLayout.rightToRight || referenceLayout.rightToLeft)
       &&  !referenceLayout.marginLeft && !referenceLayout.marginRight){

        UIView *tmpV = [UIView new];
        [view.superview addSubview:tmpV];
        
        UIView *leftRelationView;
        if(referenceLayout.leftToRight){
            leftRelationView = [pool getItemWithIdentifier:referenceLayout.leftToRight];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(leftRelationView.mas_right);
            }];
        } else {
            leftRelationView = [pool getItemWithIdentifier:referenceLayout.leftToLeft];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(leftRelationView.mas_left);
            }];
        }
        
        UIView *rightRelationView;
        if(referenceLayout.rightToLeft){
            rightRelationView = [pool getItemWithIdentifier:referenceLayout.rightToLeft];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightRelationView.mas_left);
            }];
        } else {
            rightRelationView = [pool getItemWithIdentifier:referenceLayout.rightToRight];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightRelationView.mas_right);
            }];
        }
        
        if (referenceLayout.width != nil && [DBDefines db_getUnit:referenceLayout.width] == 0) {
            //写死0的case下，自适应
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(tmpV);
                make.right.mas_equalTo(tmpV);
            }];
        }else{
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(tmpV);
            }];
        }
    } else{
        if (referenceLayout.leftToLeft) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.leftToLeft];
            CGFloat marginLeft = 0;
            if (referenceLayout.marginLeft) {
                marginLeft = [DBDefines db_getUnit:referenceLayout.marginLeft];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(relationView).offset(marginLeft);
            }];
        }
        
        if (referenceLayout.rightToRight) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.rightToRight];
            CGFloat marginRight = 0;
            if (referenceLayout.marginRight) {
                marginRight = -[DBDefines db_getUnit:referenceLayout.marginRight];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(relationView).offset(marginRight);
            }];
        }
        
        if (referenceLayout.leftToRight) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.leftToRight];
            CGFloat marginLeft = 0;
            if (referenceLayout.marginLeft) {
                marginLeft = [DBDefines db_getUnit:referenceLayout.marginLeft];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(relationView.mas_right).offset(marginLeft);
            }];
        }
        if (referenceLayout.rightToLeft) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.rightToLeft];
            CGFloat marginRight = 0;
            if (referenceLayout.marginRight) {
                marginRight = -[DBDefines db_getUnit:referenceLayout.marginRight];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(relationView.mas_left).offset(marginRight);
            }];
        }
    }
    
    //左右都有约束但间距都为0，则为居中或自适应的case
    if((referenceLayout.topToTop || referenceLayout.topToBottom)
       && (referenceLayout.bottomToBottom || referenceLayout.bottomToTop)
       &&  !referenceLayout.marginTop && !referenceLayout.marginBottom){

        UIView *tmpV = [UIView new];
        [view.superview addSubview:tmpV];
        
        UIView *topRelationView;
        if(referenceLayout.topToTop){
            topRelationView = [pool getItemWithIdentifier:referenceLayout.topToTop];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(topRelationView.mas_top);
            }];
        } else {
            topRelationView = [pool getItemWithIdentifier:referenceLayout.topToBottom];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(topRelationView.mas_bottom);
            }];
        }
        
        UIView *bottomRelationView;
        if(referenceLayout.bottomToTop){
            bottomRelationView = [pool getItemWithIdentifier:referenceLayout.bottomToTop];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(bottomRelationView.mas_top);
            }];
        } else {
            bottomRelationView = [pool getItemWithIdentifier:referenceLayout.bottomToBottom];
            [tmpV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(bottomRelationView.mas_bottom);
            }];
        }
        
        if (referenceLayout.height != nil && [DBDefines db_getUnit:referenceLayout.height] == 0) {
            //写死0的case下，自适应
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(tmpV);
                make.bottom.mas_equalTo(tmpV);
            }];
        }else{
            if(topRelationView != bottomRelationView){
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(tmpV);
                }];
            } else {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(topRelationView);
                }];
            }
        }
    } else{
        if (referenceLayout.bottomToBottom) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.bottomToBottom];
            CGFloat marginBottom = 0;
            if(referenceLayout.marginBottom){
                marginBottom = -[DBDefines db_getUnit:referenceLayout.marginBottom];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(relationView).offset(marginBottom);
            }];
        }
        if (referenceLayout.topToTop) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.topToTop];
            CGFloat marginTop = 0;
            if (referenceLayout.marginTop) {
                marginTop = [DBDefines db_getUnit:referenceLayout.marginTop];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(relationView).offset(marginTop);
            }];
        }
        
        if (referenceLayout.bottomToTop) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.bottomToTop];
            CGFloat marginBottom = 0;
            if (referenceLayout.marginBottom) {
                marginBottom = -[DBDefines db_getUnit:referenceLayout.marginBottom];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(relationView.mas_top).offset(marginBottom);
            }];
        }
        if (referenceLayout.topToBottom) {
            UIView *relationView = [pool getItemWithIdentifier:referenceLayout.topToBottom];
            CGFloat marginTop = 0;
            if (referenceLayout.marginTop) {
                marginTop = [DBDefines db_getUnit:referenceLayout.marginTop];
            }
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(relationView.mas_bottom).offset(marginTop);
            }];
        }
    }
}

@end
