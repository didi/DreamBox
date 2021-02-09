//
//  DBContainerViewFrame.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/13.
//

#import "DBXContainerViewFrame.h"
#import "DBXFrameModel.h"
#import "DBXDefines.h"
#import "DBXRenderModel.h"
#import "UIView+Yoga.h"
#import "DBXFrameLayout.h"
#import "DBXCallBack.h"
#import "UIColor+DBXColor.h"
#import "DBXParser.h"

@implementation DBXContainerViewFrame

+ (DBXContainerView *)containerViewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId delegate:(nonnull id<DBContainerViewDelegate>)delegate{
    DBXContainerViewFrame *container = [DBXContainerViewFrame viewWithRenderModel:renderModel pathid:pathId];
    container.containerDelegate = delegate;
    container.pathTid = pathId;
    container.renderModel = renderModel;
    [container frameLayoutWithContainer:container renderModel:renderModel];
    container.pathTid = pathId;
    container.userInteractionEnabled = YES;
    return container;
}

+ (DBXContainerViewFrame *)viewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId{
    DBXContainerViewFrame *view = [DBXContainerViewFrame new];
    view.callBacks = renderModel.callbacks;
    [[DBXCallBack shareInstance] bindView:view withCallBacks:view.callBacks pathId:pathId];
    return view;
}

- (void)reLoadData{
    [self.allRenderViewArray enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        if([view isKindOfClass:[DBXContainerView class]]){
            DBXContainerView *container = (DBXContainerView *)view;
            [container reLoadData];
        } else {
            if([view respondsToSelector:@selector(reload)]){
                [view performSelector:@selector(reload)];
            }
        }
    }];
}

- (void)frameLayoutWithContainer:(UIView *)container renderModel:(DBXRenderModel *)renderModel{
    CGSize contentSize = CGSizeMake([DBXDefines db_getUnit:renderModel.frameModel.width pathId:self.pathTid], [DBXDefines db_getUnit:renderModel.frameModel.height pathId:self.pathTid]);
    container.backgroundColor = [UIColor db_colorWithHexString:renderModel.backgroundColor];
    [DBXFrameLayout frameLayoutWithView:container withModel:renderModel.frameModel contentSize:CGSizeZero edgeInsets:UIEdgeInsetsZero pathId:self.pathTid];
    
    UIEdgeInsets contentEdgeInsets = [DBXFrameLayout contentRectEdgewithModel:renderModel.frameModel pathId:self.pathTid];
    
    NSArray *renderArray = renderModel.children;
    for (int i = 0; i < renderArray.count ; i ++) {
        NSDictionary *dict = renderArray[i];
        UIView *viewToLayout;
        NSString *visibleOn;
        NSString *_type = [dict objectForKey:@"_type"];
        if([_type isEqual:@"layout"]){
            DBXRenderModel *subRenderModel = [DBXRenderModel modelWithDict:dict];
            visibleOn = [DBXParser getRealValueByPathId:self.pathTid andKey:subRenderModel.visibleOn];
            UIView *subContainer = [self.containerDelegate containerViewWithRenderModel:subRenderModel pathid:self.pathTid];
            [container addSubview: subContainer];
            
            [DBXFrameLayout frameLayoutWithView:subContainer withModel:subRenderModel.frameModel contentSize:contentSize edgeInsets:contentEdgeInsets pathId:self.pathTid];
            [subContainer configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.isIncludedInLayout = NO;
            }];
            viewToLayout = subContainer;
    
        }else {
            Class cls = [[DBXFactory sharedInstance] getModelClassByType:_type];
            DBXViewModel *viewModel = [cls modelWithDict:dict];
            visibleOn = [DBXParser getRealValueByPathId:self.pathTid andKey:viewModel.visibleOn];
            UIView *view = [self modelToView:viewModel];
            //控制是否隐藏
            [view configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.isIncludedInLayout = NO;
            }];
            //添加到模型数组,渲染数组中
            [self addToAllContainer:container item:view andModel:viewModel];
            [DBXFrameLayout frameLayoutWithView:view withModel:viewModel.frameLayout contentSize:contentSize edgeInsets:contentEdgeInsets pathId:self.pathTid];
            
            viewToLayout = view;
            
        }
        
        if(visibleOn && viewToLayout){
            if ([visibleOn isEqualToString:@"0"]) {
                viewToLayout.hidden = YES;
            }else if([visibleOn isEqualToString:@"-1"]){
                viewToLayout.hidden = YES;
            } else {
                viewToLayout.hidden = NO;
            }
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
        
        [DBXDefines makeCornerWithView:self
                             cornerLT:[DBXDefines db_getUnit:self.renderModel.radiusLT pathId:self.pathTid]
                             cornerRT:[DBXDefines db_getUnit:self.renderModel.radiusRT pathId:self.pathTid]
                             cornerLB:[DBXDefines db_getUnit:self.renderModel.radiusLB pathId:self.pathTid]
                             cornerRB:[DBXDefines db_getUnit:self.renderModel.radiusRB pathId:self.pathTid]
         ];
    }
    
    if (self.renderModel.borderWidth) {
        self.layer.borderWidth = [self.renderModel.borderWidth floatValue];
    }
    
    if (self.renderModel.borderColor) {
        self.layer.borderColor = [UIColor db_colorWithHexString:self.renderModel.borderColor].CGColor;
    }
} 
@end
