//
//  DBContainerView.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import "DBContainerView.h"
#import "DBParser.h"

@implementation DBContainerView

+ (DBContainerView *)containerViewWithModel:(DBTreeModel *)model pathid:(NSString *)pathId{
    return nil;
}

- (void)reloadWithDict:(NSDictionary *)dict{
    
}

//模型到DBView
- (DBView *)modelToView:(DBViewModel *)model
{
    //解析出view
    DBView *view = [DBParser modelToView:model andPathId:self.pathTid];
    return view;
}

- (void)addToAllContainer:(UIView *)containerView item:(UIView *)itemView andModel:(DBViewModel *)viewModel
{
    if (!itemView || !viewModel) {
        return;
    }
    [self.allRenderViewArray addObject:itemView];
    [self.allRenderModelArray addObject:viewModel];
    [containerView addSubview:itemView];
    if (viewModel.modelID) {
        [self.recyclePool setItem:itemView withIdentifier:viewModel.modelID];
    }
}

#pragma mark - getter/setter
//复用池
-(DBRecyclePool *)recyclePool
{
    if (!_recyclePool) {
        _recyclePool = [DBRecyclePool new];
        self.backGroudView.modelID = @"0";
        [_recyclePool setItem:self.backGroudView withIdentifier:self.backGroudView.modelID];
    }
    return _recyclePool;
}

-(NSMutableArray *)allRenderViewArray
{
    if (_allRenderViewArray == nil) {
        _allRenderViewArray = [NSMutableArray array];
        self.backGroudView.modelID = @"0";
        [_allRenderViewArray addObject:self.backGroudView];
    }
    return _allRenderViewArray;
}

-(NSMutableArray *)allRenderModelArray
{
    if (_allRenderModelArray == nil) {
        _allRenderModelArray = [NSMutableArray array];
        DBViewModel *model = [DBViewModel new];
        model.modelID = @"0";
        [_allRenderModelArray addObject:model];
    }
    return _allRenderModelArray;
}


-(DBView *)backGroudView{
    if (!_backGroudView) {
        _backGroudView = [[DBView alloc] init];
        [self addSubview:_backGroudView];
    }
    return _backGroudView;
}
@end
