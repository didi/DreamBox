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

@implementation DBContainerViewYoga

+ (DBContainerView *)containerViewWithModel:(DBTreeModel *)model pathid:(NSString *)pathId{
    DBContainerViewYoga *container = [DBContainerViewYoga new];
    container.pathTid = pathId;
    container.treeModel = model;
    DBTreeModelYoga *yogaModel = (DBTreeModelYoga *)model;
    [container flexBoxLayoutWithContainer:container.backGroudView renderModel:yogaModel.render];
    [container makeContent];
    container.showsVerticalScrollIndicator = NO;
    container.showsHorizontalScrollIndicator = NO;
    return container;
}

+ (DBContainerView *)containerViewWithYogaModel:(DBYogaRenderModel *)yogaModel pathid:(NSString *)pathId{
    DBContainerViewYoga *container = [DBContainerViewYoga new];
    container.pathTid = pathId;
    [container flexBoxLayoutWithContainer:container.backGroudView renderModel:yogaModel];
    [container makeContent];
    container.frame = container.backGroudView.bounds;
    return container;
}

- (void)flexBoxLayoutWithContainer:(UIView *)container renderModel:(DBYogaRenderModel *)renderModel
{
    [DBFlexBoxLayout flexLayoutView:container withModel:renderModel.yogaModel];
    container.backgroundColor = [UIColor db_colorWithHexString:renderModel.backgroundColor];
    
    NSArray *renderArray = renderModel.children;
    for (int i = 0; i < renderArray.count ; i ++) {
        NSDictionary *dict = renderArray[i];
        NSString *type = [dict objectForKey:@"type"];
        if([type isEqual:@"yoga"]){
            //嵌套
            DBYogaRenderModel *subRenderModel = [DBYogaRenderModel modelWithDict:dict];
            UIView *subContainer = [UIView new];
            [container addSubview: subContainer];
            [self flexBoxLayoutWithContainer:subContainer renderModel:subRenderModel];
        } else {
            Class cls = [[DBFactory sharedInstance] getModelClassByType:type];
            DBViewModel *viewModel = [cls modelWithDict:dict];
            UIView *view = [self modelToView:viewModel];
            //添加到模型数组,渲染数组中
            [self addToAllContainer:container item:view andModel:viewModel];
            [DBFlexBoxLayout flexLayoutView:view withModel:viewModel.yogaLayout];
        }
    }
    
    [container.yoga applyLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
}

- (void)reloadWithDict:(NSDictionary *)dict{
    [[DBPool shareDBPool] setObject:dict ToDBMetaPoolWithPathId:self.pathTid];
    
    [self.allRenderViewArray enumerateObjectsUsingBlock:^(DBBaseView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        [view reload];
        [view.yoga markDirty];
    }];
    
    [self.backGroudView.yoga applyLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
    self.frame = self.backGroudView.bounds;
}

- (void)makeContent{
    if(self.treeModel.scroll.length > 0){
        self.scrollEnabled = YES;
        self.bounces = NO;
        if([self.treeModel.scroll isEqualToString:@"horizontal"]){
            [self setContentSize:self.backGroudView.frame.size];
        }
        if([self.treeModel.scroll isEqualToString:@"vertical"]){
            [self setContentSize:self.backGroudView.frame.size];
        }
    } else {
        self.scrollEnabled = NO;
    }
}



@end
