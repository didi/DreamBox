//
//  DBContainerViewYoga.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import "DBXContainerViewYoga.h"
#import "DBXParser.h"
#import "DBXYogaModel.h"
#import "UIColor+DBXColor.h"
#import "DBXFactory.h"
#import "UIView+Yoga.h"
#import "DBXPool.h"
#import "DBXFlexBoxLayout.h"
#import "DBXContainerViewFrame.h"
#import "DBXFrameModel.h"
#import "DBXRenderModel.h"
#import "DBXValidJudge.h"
#import "DBXWrapperManager.h"
#import "DBXDefines.h"
#import "DBXCallBack.h"
#import "NSDictionary+DBXExtends.h"

@implementation DBXContainerViewYoga
#pragma mark - ststic
+ (DBXContainerView *)containerViewWithModel:(DBXTreeModel *)model pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate{
    DBXTreeModelYoga *yogaModel = (DBXTreeModelYoga *)model;
    DBXContainerViewYoga *container = [DBXContainerViewYoga viewWithRenderModel:yogaModel.render pathid:pathId];
    container.containerDelegate = delegate;
    container.pathTid = pathId;
    container.treeModel = model;
    container.renderModel = yogaModel.render;
    [container refreshImageWithSrc:yogaModel.render.background];
    [container flexBoxLayoutWithContainer:container renderModel:yogaModel.render];
    container.userInteractionEnabled = YES;
    return container;
}

+ (DBXContainerView *)containerViewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId delegate:(id<DBContainerViewDelegate>)delegate
{
    DBXContainerViewYoga *container = [DBXContainerViewYoga viewWithRenderModel:renderModel pathid:pathId];
    container.containerDelegate = delegate;
    container.renderModel = renderModel;
    container.pathTid = pathId;
    [container refreshImageWithSrc:renderModel.background];
    [container flexBoxLayoutWithContainer:container renderModel:renderModel];
    container.userInteractionEnabled = YES;
    return container;
}

#pragma mark - public
- (void)reloadWithMetaDict:(NSDictionary *)dict{
    [[DBXPool shareDBPool] setObject:dict ToDBMetaPoolWithPathId:self.pathTid];
    [self reLoadData];
}

- (void)reloadWithExtDict:(NSDictionary *)dict {
    [[DBXPool shareDBPool] setObject:dict ToDBExtPoolWithPathId:self.pathTid];
    [self reLoadData];
}

#pragma mark - private
#pragma mark -- 构建逻辑
- (void)flexBoxLayoutWithContainer:(UIView *)container renderModel:(DBXRenderModel *)renderModel
{
    [DBXFlexBoxLayout flexLayoutView:container withModel:renderModel.yogaModel pathId:self.pathTid];
    NSString *color = [DBXParser getRealValueByPathId:self.pathTid andKey:renderModel.backgroundColor];
    container.backgroundColor = [UIColor db_colorWithHexString:color];

    NSArray *renderArray = renderModel.children;
    self.renderModelArray = renderArray;
    for (int i = 0; i < renderArray.count ; i ++) {
        NSDictionary *dict = renderArray[i];
        NSString *_type = [dict objectForKey:@"_type"];
        if([_type isEqual:@"layout"]){
            //1、model
            DBXRenderModel *subRenderModel = [DBXRenderModel modelWithDict:dict];
            [self layoutWithViewModel:subRenderModel];
        }else {
            //1、model
            Class cls = [[DBXFactory sharedInstance] getModelClassByType:_type];
            DBXViewModel *viewModel = [cls modelWithDict:dict];
            [self layoutWithViewModel:viewModel];
        }
    }

    [container.yoga applyLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
    
    [self configCornerRadius];
}

- (void)layoutWithViewModel:(DBXViewModel *)model {
    UIView *view;
    if([model._type isEqual:@"layout"]){
        view = [self.containerDelegate containerViewWithRenderModel:(DBXRenderModel *)model pathid:self.pathTid];
    } else {
        view = [self modelToView:model];
    }
    [self addSubview:view];
    
    NSString *visibleOn = [DBXParser getRealValueByPathId:self.pathTid andKey:model.visibleOn];
    [self.subViewsDict db_setValue:view forKey:model.modelID];
    if ([visibleOn isEqualToString:@"-1"]){
        [DBXFlexBoxLayout removeViewFromFlex:view];
    } else {
        [self.subViewsDictNoGone db_setValue:view forKey:model.modelID];
        if([model._type isEqual:@"layout"]){
            [DBXFlexBoxLayout flexLayoutView:view withModel:((DBXRenderModel *)model).yogaModel pathId:self.pathTid];
        } else {
            [DBXFlexBoxLayout flexLayoutView:view withModel:model.yogaLayout pathId:self.pathTid];
        }
        if ([visibleOn isEqualToString:@"0"]) {
            view.hidden = YES;
        } else{
            view.hidden = NO;
        }
    }
}

#pragma mark -- 重载逻辑
- (void)reLoadData{
    NSString *color = [DBXParser getRealValueByPathId:self.pathTid andKey:self.renderModel.backgroundColor];
    self.backgroundColor = [UIColor db_colorWithHexString:color];
    
    for(int i = 0; i < self.renderModelArray.count; i++){
        NSDictionary *dict = self.renderModelArray[i];
        NSString *_type = [dict objectForKey:@"_type"];
        if([_type isEqual:@"layout"]){
            DBXRenderModel *subRenderModel = [DBXRenderModel modelWithDict:dict];
            [self relayoutWithViewModel:subRenderModel];
        } else {
            Class cls = [[DBXFactory sharedInstance] getModelClassByType:_type];
            DBXViewModel *viewModel = [cls modelWithDict:dict];
            [self relayoutWithViewModel:viewModel];
        }
    }
    
    [self.yoga applyLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
}

- (void)relayoutWithViewModel:(DBXViewModel *)model{
    NSString *visibleOn = [DBXParser getRealValueByPathId:self.pathTid andKey:model.visibleOn];
    if ([visibleOn isEqualToString:@"-1"]){
        //gone
        UIView *view = [self.subViewsDictNoGone db_objectForKey:model.modelID];
        if(view){
            //非gone->gone
            [DBXFlexBoxLayout removeViewFromFlex:view];
            [self.subViewsDictNoGone removeObjectForKey:model.modelID];
        } else {
            //gone->gone
        }
    } else {
        //非gone
        UIView *view = [self.subViewsDictNoGone db_objectForKey:model.modelID];
        if(view){
        } else {
            //gone->非gone
            view = [self.subViewsDict objectForKey:model.modelID];
            [DBXFlexBoxLayout addViewIntoFlex:view];
            [self.subViewsDictNoGone db_setValue:view forKey:model.modelID];
        }
        if(view){
            if([model._type isEqual:@"layout"]){
                DBXContainerView *container = (DBXContainerView *)view;
                if([container respondsToSelector:@selector(reLoadData)]){
                    [container reLoadData];
                }
                [DBXFlexBoxLayout flexLayoutView:view withModel:((DBXRenderModel *)model).yogaModel pathId:self.pathTid];
            } else {
                if([view respondsToSelector:@selector(reload)]){
                    [view performSelector:@selector(reload)];
                }
                [DBXFlexBoxLayout flexLayoutView:view withModel:model.yogaLayout pathId:self.pathTid];
            }
            //非gone->非gone
            if ([visibleOn isEqualToString:@"0"]) {
                view.hidden = YES;
            } else{
                view.hidden = NO;
            }
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

#pragma mark -- others
+ (DBXContainerViewYoga *)viewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId{
    DBXContainerViewYoga *view = [DBXContainerViewYoga new];
    view.callBacks = renderModel.callbacks;
    [[DBXCallBack shareInstance] bindView:view withCallBacks:view.callBacks pathId:pathId];
    return view;
}

- (void)configCornerRadius{
    
    NSString *radius = [DBXParser getRealValueByPathId:self.pathTid andKey:self.renderModel.radius];
    NSString *radiusLT = [DBXParser getRealValueByPathId:self.pathTid andKey:self.renderModel.radiusLT];
    NSString *radiusRT = [DBXParser getRealValueByPathId:self.pathTid andKey:self.renderModel.radiusRT];
    NSString *radiusLB = [DBXParser getRealValueByPathId:self.pathTid andKey:self.renderModel.radiusLB];
    NSString *radiusRB = [DBXParser getRealValueByPathId:self.pathTid andKey:self.renderModel.radiusRB];
    NSString *borderWidth = [DBXParser getRealValueByPathId:self.pathTid andKey:self.renderModel.borderWidth];
    NSString *borderColor = [DBXParser getRealValueByPathId:self.pathTid andKey:self.renderModel.borderColor];
    
    if(radius) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = [DBXDefines db_getUnit:radius pathId:self.pathTid];
    }
    if(radiusLT
       || radiusRT
       || radiusLB
       || radiusRB){
        
        [DBXDefines makeCornerWithView:self
                             cornerLT:[DBXDefines db_getUnit:radiusLT pathId:self.pathTid]
                             cornerRT:[DBXDefines db_getUnit:radiusRT pathId:self.pathTid]
                             cornerLB:[DBXDefines db_getUnit:radiusLB pathId:self.pathTid]
                             cornerRB:[DBXDefines db_getUnit:radiusRB pathId:self.pathTid]
         ];
    }
    
    if (borderWidth) {
        self.layer.borderWidth = [borderWidth floatValue];
    }
    
    if (borderColor) {
        self.layer.borderColor = [UIColor db_colorWithHexString:borderColor].CGColor;
    }
}

- (void)refreshImageWithSrc:(NSString *)srcStr {
    if(srcStr.length > 0){
        NSString *src = [DBXParser getRealValueByPathId:self.pathTid andKey:srcStr];
        NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:self.pathTid];
        if ([DBXValidJudge isValidString:src]) {
            __weak typeof(self) weakSelf = self;
            [[DBXWrapperManager sharedManager] imageLoadService:self accessKey:accessKey setImageUrl:src callback:^(UIImage * _Nonnull image) {
                if(image){
                        weakSelf.image = image;
                    }
                }
            ];
        }
    }
}


@end
