//
//  DBRenderFactory.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import "DBXRenderFactory.h"
#import "DBXContainerViewYoga.h"
#import "DBXContainerViewFrame.h"

@interface DBXRenderFactory () <DBContainerViewDelegate>
@end

@implementation DBXRenderFactory

+ (instancetype)sharedFactory {
    static DBXRenderFactory *factory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory =  [[DBXRenderFactory alloc] init];
    });
    return factory;
}


+ (DBXContainerView *)renderViewWithTreeModel:(DBXTreeModel *)treeModel pathid:(NSString *)pathId{
    DBXContainerView *containerView = [DBXContainerViewYoga containerViewWithModel:treeModel pathid:pathId delegate:[self sharedFactory]];
    return containerView;
}


+ (DBXContainerView *)renderViewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId{
    DBXContainerView *containerView = [DBXContainerViewYoga containerViewWithRenderModel:renderModel pathid:pathId delegate:[self sharedFactory]];
    return containerView;
}

//递归创建子容器
- (DBXContainerView *)containerViewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId {
    DBXContainerView *subContainer = nil;
    if([renderModel.type isEqual:@"yoga"]){
        subContainer = [DBXContainerViewYoga containerViewWithRenderModel:renderModel pathid:pathId delegate:self];
    } else if ([renderModel.type isEqual:@"frame"]){
        subContainer = [DBXContainerViewFrame containerViewWithRenderModel:renderModel pathid:pathId delegate:self];
    }
    return subContainer;
}

@end
