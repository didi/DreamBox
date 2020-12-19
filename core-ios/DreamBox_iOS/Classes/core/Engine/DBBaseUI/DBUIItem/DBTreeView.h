//
//  DBView.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBViewModel.h"
#import "DBView.h"

@class DBTreeModel;


NS_ASSUME_NONNULL_BEGIN
typedef void(^DBTreeRenderBlock)(BOOL successed,NSError * _Nullable error);
typedef void(^DBTreeEventBlock)(NSString *evendID, NSDictionary *paramDict, NSDictionary *callbackData);

@interface DBTreeView : DBView
 
@property (nonatomic ,copy, readonly) NSString *accessKey;
//根据Tid
- (void)loadWithTemplateId:(NSString *)tid accessKey:(NSString *)accessKey extData:(NSDictionary *)ext completionBlock:(DBTreeRenderBlock)completionBlock;
//明文Json字符串
- (DBTreeView *)initWithJsonSting:(NSString *)jsonString extMeta:(NSDictionary *)ext accessKey:(NSString *)accessKey tid:(NSString *)tid;
//加密Json字符串
- (DBTreeView *)initWithData:(NSString *)data extMeta:(NSDictionary *)ext accessKey:(NSString *)accessKey tid:(NSString *)tid;
//明文dict
- (DBTreeView *)initWithDict:(NSDictionary *)treeDict extMeta:(NSDictionary *)ext accessKey:(NSString *)accessKey tid:(NSString *)tid;

// reload方法，for catalog
- (void)reloadWithData:(NSString *)data extMeta:(NSDictionary *)ext;
    
// !替换! 用户ext
- (void)bindExtensionMetaData:(NSDictionary *)ext;

//刷新方法
-(void)reloadTreeView;

/**
注册D2N事件

@param eventID           事件ID
@param block               事件绑定回调
*/
-(void)registerEventWithEventID:(NSString *)eventID andBlock:(DBTreeEventBlock)block;
//获取D2N事件
- (DBTreeEventBlock)eventBlockWithEventId:(NSString *)eventID;
/**
native触发D2N事件携带的回调

@param callBackData           D2N事件携带的回调(透传)
@param data                       N2D数据
*/
 - (void)handleDBCallBack:(NSDictionary *)callBackData data:(id)data;

/**
 添加N2D  bridge事件监听

@param onEventDict : N2D事件携带的回调
*/
- (void)regiterOnEvent:(NSDictionary *)onEventDict;
/**-(void)regiterOnEvent:(NSDictionary *)onEventDict
发送N2D事件

@param eid           事件ID
@param data           N2D数据
*/
- (void)sendEventWithEventID:(NSString *)eid data:(id)data;
//直接用renderArray绘制treeView
+ (DBTreeView *)treeViewWithRender:(NSArray *)renderArray meta:(NSDictionary *)metaDict accessKey:(NSString *)accessKey tid:(NSString *)tid;
//直接用renderArray绘制treeView
+ (DBTreeView *)treeViewWithRender:(NSArray *)renderArray accessKey:(NSString *)accessKey tid:(NSString *)tid;

- (CGFloat)maxXOfTreeView;
- (CGFloat)maxYOfTreeView;

#pragma mark - DEBUG
- (void)hiddenDebugView;
@end

NS_ASSUME_NONNULL_END
