//
//  DBContainerView.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import <UIKit/UIKit.h>
#import "DBXViewModel.h"
#import "DBXView.h"
#import "DBXRecyclePool.h"
#import "DBXFactory.h"

NS_ASSUME_NONNULL_BEGIN

@class DBXContainerView;

@protocol DBContainerViewDelegate <NSObject>

@required
- (DBXContainerView *)containerViewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId;

@end

@interface DBXContainerView : UIImageView


@property (nonatomic, weak) id<DBContainerViewDelegate> containerDelegate;
@property (nonatomic, strong) DBXTreeModel *treeModel;
@property (nonatomic, strong) DBXRenderModel *renderModel;
@property (nonatomic, copy) NSString *pathTid;

@property (nonatomic, strong) DBXView *backGroudView;
@property (nonatomic, strong) DBXRecyclePool *recyclePool;
@property (nonatomic, strong) NSMutableArray *allRenderViewArray;
@property (nonatomic, strong) NSMutableArray *allRenderModelArray;
@property (nonatomic, strong) NSArray *callBacks;
@property (nonatomic, strong) NSArray *renderModelArray;
@property (nonatomic, strong) NSMutableDictionary *subViewsDict;
@property (nonatomic, strong) NSMutableDictionary *subViewsDictNoGone;


+ (DBXContainerView *)containerViewWithModel:(DBXTreeModel *)model pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate;
+ (DBXContainerView *)containerViewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate;


- (DBXBaseView *)modelToView:(DBXViewModel *)model;

- (void)addToAllContainer:(UIView *)containerView item:(UIView *)itemView andModel:(DBXViewModel *)viewModel;

- (void)reloadWithMetaDict:(NSDictionary *)dict;

- (void)reloadWithExtDict:(NSDictionary *)dict;

- (void)reLoadData;

@end

NS_ASSUME_NONNULL_END
