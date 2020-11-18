//
//  DBDebugService.h
//  DBWSSDemoi
//
//  Created by zhangchu on 2020/7/14.
//  Copyright © 2020 zhangchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBTreeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBDebugService : NSObject

@property (nonatomic,strong) DBTreeView *dbView;

+ (instancetype)shareInstance;

/**
展示debug按钮
*/
-(void)showDebugbutton;

/**
隐藏debug按钮
*/
- (void)hideDebugbutton;

/**
刷新当前DBTreeView
*/
- (void)refresh;

/**
绑定socket数据到DBTreeView
*/
- (void)bindWithWss:(NSString *)wss;

@end

NS_ASSUME_NONNULL_END
