//
//  DBToast.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/17.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXToast.h"
#import "UIView+DBXToast.h"
#import "DBXHelper.h"
@implementation DBXToast

+ (void)showToast:(NSString *)str {
    
    [DBXToast showToast:str duration:1.5f];
}
+ (void)showToast:(NSString *)str longTime:(BOOL)longTime {
    
    CGFloat duration = longTime ? 3.f : 1.5f;
    [DBXToast showToast:str duration:duration];
}

+ (void)showToast:(NSString *)str duration:(NSTimeInterval)duration {
    
//    [DBRootViewController().view db_makeToast:str duration:duration position:DBToastPositionCenter];
    [[UIApplication sharedApplication].keyWindow db_makeToast:str duration:duration position:DBXToastPositionCenter];
}

@end
