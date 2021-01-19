//
//  DBContainerViewFrame.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/13.
//

#import "DBContainerViewFrame.h"
#import "DBFrameModel.h"
#import "DBDefines.h"
#import "DBRenderModel.h"
#import "DBDefines.h"
#import "UIView+Yoga.h"
#import "DBFrameLayout.h"
#import "DBCallBack.h"

@implementation DBContainerViewFrame

+ (DBContainerView *)containerViewWithRenderModel:(DBRenderModel *)renderModel pathid:(NSString *)pathId delegate:(nonnull id<DBContainerViewDelegate>)delegate{
    DBContainerViewFrame *container = [DBContainerViewFrame viewWithRenderModel:renderModel pathid:pathId];
    container.containerDelegate = delegate;
    container.pathTid = pathId;
    container.renderModel = renderModel;
    [container frameLayoutWithContainer:container renderModel:renderModel];
    container.pathTid = pathId;
    container.userInteractionEnabled = YES;
    return container;
}

+ (DBContainerViewFrame *)viewWithRenderModel:(DBRenderModel *)renderModel pathid:(NSString *)pathId{
    DBContainerViewFrame *view = [DBContainerViewFrame new];
    view.callBacks = renderModel.callbacks;
    [DBCallBack bindView:view withCallBacks:view.callBacks pathId:pathId];
    return view;
}

- (void)frameLayoutWithContainer:(UIView *)container renderModel:(DBRenderModel *)renderModel{
    CGSize contentSize = CGSizeMake([DBDefines db_getUnit:renderModel.frameModel.width], [DBDefines db_getUnit:renderModel.frameModel.height]);
    
    [DBFrameLayout frameLayoutWithView:container withModel:renderModel.frameModel contentSize:CGSizeZero edgeInsets:UIEdgeInsetsZero];
    
    UIEdgeInsets contentEdgeInsets = [DBFrameLayout contentRectEdgewithModel:renderModel.frameModel];
    
    NSArray *renderArray = renderModel.children;
    for (int i = 0; i < renderArray.count ; i ++) {
        NSDictionary *dict = renderArray[i];
        NSString *_type = [dict objectForKey:@"_type"];
        if([_type isEqual:@"layout"]){
            DBRenderModel *subRenderModel = [DBRenderModel modelWithDict:dict];
            UIView *subContainer = [self.containerDelegate containerViewWithRenderModel:subRenderModel pathid:self.pathTid];
            [container addSubview: subContainer];
            
            [DBFrameLayout frameLayoutWithView:subContainer withModel:subRenderModel.frameModel contentSize:contentSize edgeInsets:contentEdgeInsets];
            [subContainer configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.isEnabled = NO;
                layout.isIncludedInLayout = NO;
            }];
        }else {
            Class cls = [[DBFactory sharedInstance] getModelClassByType:_type];
            DBViewModel *viewModel = [cls modelWithDict:dict];
            UIView *view = [self modelToView:viewModel];
            [view configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.isEnabled = NO;
                layout.isIncludedInLayout = NO;
            }];
            //添加到模型数组,渲染数组中
            [self addToAllContainer:container item:view andModel:viewModel];
            [DBFrameLayout frameLayoutWithView:view withModel:viewModel.frameLayout contentSize:contentSize edgeInsets:contentEdgeInsets];
        }
    }
    
    //圆角处理
    if(self.renderModel.radius) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = [self.renderModel.radius floatValue];
    }
    if(self.renderModel.radiusLT
       || self.renderModel.radiusRT
       || self.renderModel.radiusLB
       || self.renderModel.radiusRB){
        
        [DBDefines makeCornerWithView:self
                             cornerLT:[DBDefines db_getUnit:self.renderModel.radiusLT]
                             cornerRT:[DBDefines db_getUnit:self.renderModel.radiusRT]
                             cornerLB:[DBDefines db_getUnit:self.renderModel.radiusLB]
                             cornerRB:[DBDefines db_getUnit:self.renderModel.radiusRB]
         ];
    }
}
@end
