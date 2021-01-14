//
//  DBContainerViewYoga.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import "DBContainerViewYoga.h"
#import "DBParser.h"
#import "DBYogaModel.h"
#import "UIColor+DBColor.h"
#import "DBFactory.h"
#import "UIView+Yoga.h"
#import "DBPool.h"
#import "DBFlexBoxLayout.h"
#import "DBContainerViewFrame.h"
#import "DBFrameModel.h"
#import "DBRenderModel.h"

@implementation DBContainerViewYoga

+ (DBContainerView *)containerViewWithModel:(DBTreeModel *)model pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate{
    DBContainerViewYoga *container = [DBContainerViewYoga new];
    container.containerDelegate = delegate;
    container.pathTid = pathId;
    container.treeModel = model;
    DBTreeModelYoga *yogaModel = (DBTreeModelYoga *)model;
    [container flexBoxLayoutWithContainer:container renderModel:yogaModel.render];
//    [container makeContent];
    container.showsVerticalScrollIndicator = NO;
    container.showsHorizontalScrollIndicator = NO;
    return container;
}

+ (DBContainerView *)containerViewWithRenderModel:(DBRenderModel *)renderModel pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate
{
    DBContainerViewYoga *container = [DBContainerViewYoga new];
    container.containerDelegate = delegate;
    container.pathTid = pathId;
    [container flexBoxLayoutWithContainer:container renderModel:renderModel];
//    [container makeContent];
    return container;
}

- (void)flexBoxLayoutWithContainer:(UIView *)container renderModel:(DBRenderModel *)renderModel
{
    [DBFlexBoxLayout flexLayoutView:container withModel:renderModel.yogaModel];
    container.backgroundColor = [UIColor db_colorWithHexString:renderModel.backgroundColor];

    NSArray *renderArray = renderModel.children;
    for (int i = 0; i < renderArray.count ; i ++) {
        NSDictionary *dict = renderArray[i];
        NSString *_type = [dict objectForKey:@"_type"];
        if([_type isEqual:@"layout"]){
            DBRenderModel *subRenderModel = [DBRenderModel modelWithDict:dict];
            UIView *subContainer = [self.containerDelegate containerViewWithRenderModel:subRenderModel pathid:self.pathTid];
            [container addSubview: subContainer];
            [DBFlexBoxLayout flexLayoutView:subContainer withModel:subRenderModel.yogaModel];
        }else {
            Class cls = [[DBFactory sharedInstance] getModelClassByType:_type];
            DBViewModel *viewModel = [cls modelWithDict:dict];
            UIView *view = [self modelToView:viewModel];
            //添加到模型数组,渲染数组中
            [self addToAllContainer:container item:view andModel:viewModel];
            [DBFlexBoxLayout flexLayoutView:view withModel:viewModel.yogaLayout];
        }
    }

    [container.yoga applyLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
}

- (void)reloadWithMetaDict:(NSDictionary *)dict{
    [[DBPool shareDBPool] setObject:dict ToDBMetaPoolWithPathId:self.pathTid];
    [self reLayout];
}

- (void)reloadWithExtDict:(NSDictionary *)dict {
    [[DBPool shareDBPool] setObject:dict ToDBExtPoolWithPathId:self.pathTid];
    [self reLayout];
}

- (void)reLayout{
    [self.allRenderViewArray enumerateObjectsUsingBlock:^(DBBaseView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        [view reload];
        [view.yoga markDirty];
    }];
    
    [self.yoga applyLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
}

//- (void)makeContent{
//    if(self.treeModel.scroll.length > 0){
//        self.scrollEnabled = YES;
//        self.bounces = NO;
//        if([self.treeModel.scroll isEqualToString:@"horizontal"]){
//            [self setContentSize:self.backGroudView.frame.size];
//        }
//        if([self.treeModel.scroll isEqualToString:@"vertical"]){
//            [self setContentSize:self.backGroudView.frame.size];
//        }
//    } else {
//        self.scrollEnabled = NO;
//    }
//}



@end
