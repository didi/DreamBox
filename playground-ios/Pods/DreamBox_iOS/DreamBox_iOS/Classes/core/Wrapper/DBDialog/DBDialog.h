//
//  DBDialog.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/17.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
typedef void (^DBAlertClickBlock)(void);
@interface DBDialog : NSObject

/**
 两个按钮的alert

 @param title             title
 @param message           message
 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitle  其他按钮标题
 @param cancelBlock       取消按钮回调
 @param otherBlock        其他按钮回调
 */
+ (void)showAlertViewWithTitle:(nullable NSString *)title
                       message:(nullable NSString *)message
             cancelButtonTitle:(nullable NSString *)cancelButtonTitle
              otherButtonTitle:(nullable NSString *)otherButtonTitle
             cancelButtonBlock:(nullable DBAlertClickBlock)cancelBlock
              otherButtonBlock:(nullable DBAlertClickBlock)otherBlock;


@end

NS_ASSUME_NONNULL_END
