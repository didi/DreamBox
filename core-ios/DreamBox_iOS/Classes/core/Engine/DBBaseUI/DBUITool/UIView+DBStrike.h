//
//  UIView+DCInteraction.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/20.
//  Copyright © 2020 didi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//处理点击长按

@interface UIView (DBStrike)

@property (nonatomic, copy) dispatch_block_t viewVisible;
@property (nonatomic, copy) dispatch_block_t viewInVisible;

//添加点击
- (void)db_addTapGestureActionWithBlock:(void (^)(UITapGestureRecognizer *tapAction))block;

//长按手势
- (void)db_addLongPressGestureActionWithBlock:(void (^)(UILongPressGestureRecognizer *longPressAction))block;

//添加显示关联block
- (void)addViewVisible:(dispatch_block_t)block andKey:(const void * _Nonnull)key;
    

//添加关联block消失时调用
- (void)addViewInVisible:(dispatch_block_t)block andKey:(const void * _Nonnull)key;

@end

NS_ASSUME_NONNULL_END
