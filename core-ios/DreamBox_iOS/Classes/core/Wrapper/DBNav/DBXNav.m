//
//  DBNav.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXNav.h"
#import "DBXHelper.h"
#import <UIKit/UIKit.h>
@implementation DBXNav

+ (void)navigatorBySchema:(NSString *)schema {
    
    if (![DBXValidJudge isValidString:schema]) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:schema];
    if (url) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {

                }];
            } else {
                // Fallback on earlier versions
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

@end
