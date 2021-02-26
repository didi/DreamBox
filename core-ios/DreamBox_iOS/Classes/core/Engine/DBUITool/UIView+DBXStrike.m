//
//  UIView+DCInteraction.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/20.
//  Copyright © 2020 didi. All rights reserved.
//

#import "UIView+DBXStrike.h"
#import <objc/runtime.h>

static char const kDBActionHandlerTapBlockKey;
static char const kDBActionHandlerTapGestureKey;
static char const kDBActionHandlerLongPressBlockKey;
static char const kDBActionHandlerLongPressGestureKey;
static char const kDBActionHandlerOnVisibleKey;
static char const kDBActionHandlerOnInVisibleKey;
static char const kDBActionHandlerOnPositiveKey;
static char const kDBActionHandlerOnNegativeKey;


@interface UIView ()

@property (nonatomic, strong) NSNumber  *userInteractionNumbers; //

@end

@implementation UIView (DBXStrike)

#pragma mark - gesture block
- (void)db_addTapGestureActionWithBlock:(void (^)(UITapGestureRecognizer *))block{
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDBActionHandlerTapGestureKey);
    if (!gesture){
        self.userInteractionEnabled = YES;
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(db_handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDBActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kDBActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)db_handleActionForTapGesture:(UITapGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized){
        void(^action)(UITapGestureRecognizer *tapAction) = objc_getAssociatedObject(self, &kDBActionHandlerTapBlockKey);
        if (action){
            action(gesture);
        }
    }
}

- (void)db_addLongPressGestureActionWithBlock:(void (^)(UILongPressGestureRecognizer *))block{
    UILongPressGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDBActionHandlerLongPressGestureKey);
    if (!gesture){
        self.userInteractionEnabled = YES;
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(db_handleActionForLongPressGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDBActionHandlerLongPressGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kDBActionHandlerLongPressBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)db_handleActionForLongPressGesture:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan){
        void(^action)(UILongPressGestureRecognizer *longPressAction) = objc_getAssociatedObject(self, &kDBActionHandlerLongPressBlockKey);
        if (action){
            action(gesture);
        }
    }
}

//添加关联block显示时调用
- (void)setViewVisible:(dispatch_block_t)block{
    objc_setAssociatedObject(self,&kDBActionHandlerOnVisibleKey, block, OBJC_ASSOCIATION_COPY);
}

- (dispatch_block_t)viewVisible{
    return objc_getAssociatedObject(self, &kDBActionHandlerOnVisibleKey);
}


//添加关联block消失时调用
- (void)setViewInVisible:(dispatch_block_t)block{
    objc_setAssociatedObject(self,&kDBActionHandlerOnInVisibleKey, block, OBJC_ASSOCIATION_COPY);
}

- (dispatch_block_t)viewInVisible{
    return objc_getAssociatedObject(self, &kDBActionHandlerOnInVisibleKey);
}

@end
