//
//  DBNav.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBNav.h"
#import "DBHelper.h"
#import <UIKit/UIKit.h>
@implementation DBNav

+ (void)navigatorBySchema:(NSString *)schema {
    
    if (![DBValidJudge isValidString:schema]) {
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
