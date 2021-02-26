//
//  DBContainerView.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import "DBXContainerView.h"
#import "DBXParser.h"
#import "NSArray+DBXExtends.h"

@implementation DBXContainerView

+ (DBXContainerView *)containerViewWithModel:(DBXTreeModel *)model pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate {
    return nil;
}

+ (DBXContainerView *)containerViewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate{
    return nil;
}

- (void)reloadWithMetaDict:(NSDictionary *)dict{
    
}

- (void)reloadWithExtDict:(NSDictionary *)dict {
    
}

- (void)reLoadData{
    
}

//模型到DBView
- (DBXBaseView *)modelToView:(DBXViewModel *)model
{
    //解析出view
    DBXBaseView *view = [DBXParser modelToView:model andPathId:self.pathTid];
    return view;
}

- (void)addToAllContainer:(UIView *)containerView item:(UIView *)itemView andModel:(DBXViewModel *)viewModel
{
    if (!itemView || !viewModel) {
        return;
    }
    [self.allRenderViewArray db_addObject:itemView];
    [self.allRenderModelArray db_addObject:viewModel];
    [containerView addSubview:itemView];
    if (viewModel.modelID) {
        [self.recyclePool setItem:itemView withIdentifier:viewModel.modelID];
    }
}

#pragma mark - getter/setter
//复用池
-(DBXRecyclePool *)recyclePool
{
    if (!_recyclePool) {
        _recyclePool = [DBXRecyclePool new];
    }
    return _recyclePool;
}

-(NSMutableArray *)allRenderViewArray
{
    if (_allRenderViewArray == nil) {
        _allRenderViewArray = [NSMutableArray array];
    }
    return _allRenderViewArray;
}

-(NSMutableArray *)allRenderModelArray
{
    if (_allRenderModelArray == nil) {
        _allRenderModelArray = [NSMutableArray array];
        DBXViewModel *model = [DBXViewModel new];
        model.modelID = @"0";
        [_allRenderModelArray db_addObject:model];
    }
    return _allRenderModelArray;
}


//-(DBXView *)backGroudView{
//    if (!_backGroudView) {
//        _backGroudView = [[DBView alloc] init];
//        [self addSubview:_backGroudView];
//    }
//    return _backGroudView;
//}

- (NSMutableDictionary *)subViewsDict{
    if(!_subViewsDict){
        _subViewsDict = [NSMutableDictionary new];
    }
    return _subViewsDict;
}

- (NSMutableDictionary *)subViewsDictNoGone{
    if(!_subViewsDictNoGone){
        _subViewsDictNoGone = [NSMutableDictionary new];
    }
    return _subViewsDictNoGone;
}
@end
