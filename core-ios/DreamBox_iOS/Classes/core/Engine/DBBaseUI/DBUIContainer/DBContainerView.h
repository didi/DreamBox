//
//  DBContainerView.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import <UIKit/UIKit.h>
#import "DBViewModel.h"
#import "DBView.h"
#import "DBRecyclePool.h"
#import "DBFactory.h"

NS_ASSUME_NONNULL_BEGIN

@class DBContainerView;

@protocol DBContainerViewDelegate <NSObject>

@required
- (DBContainerView *)containerViewWithRenderModel:(DBRenderModel *)renderModel pathid:(NSString *)pathId;

@end

@interface DBContainerView : UIScrollView


@property (nonatomic, weak) id<DBContainerViewDelegate> containerDelegate;
@property (nonatomic, strong) DBTreeModel *treeModel;
@property (nonatomic, copy) NSString *pathTid;

@property (nonatomic, strong) DBView *backGroudView;
@property (nonatomic, strong) DBRecyclePool *recyclePool;
@property (nonatomic, strong) NSMutableArray *allRenderViewArray;
@property (nonatomic, strong) NSMutableArray *allRenderModelArray;

+ (DBContainerView *)containerViewWithModel:(DBTreeModel *)model pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate;
+ (DBContainerView *)containerViewWithRenderModel:(DBRenderModel *)renderModel pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate;


- (DBView *)modelToView:(DBViewModel *)model;

- (void)addToAllContainer:(UIView *)containerView item:(UIView *)itemView andModel:(DBViewModel *)viewModel;

- (void)reloadWithMetaDict:(NSDictionary *)dict;

- (void)reloadWithExtDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
