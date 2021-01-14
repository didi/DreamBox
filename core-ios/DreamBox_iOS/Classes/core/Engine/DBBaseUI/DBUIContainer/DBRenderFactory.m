//
//  DBRenderFactory.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import "DBRenderFactory.h"
#import "DBContainerViewYoga.h"
#import "DBContainerViewFrame.h"

@interface DBRenderFactory () <DBContainerViewDelegate>
@end

@implementation DBRenderFactory

+ (instancetype)sharedFactory {
    static DBRenderFactory *factory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory =  [[DBRenderFactory alloc] init];
    });
    return factory;
}


+ (DBContainerView *)renderViewWithTreeModel:(DBTreeModel *)treeModel pathid:(NSString *)pathId{
    DBContainerView *containerView = [DBContainerViewYoga containerViewWithModel:treeModel pathid:pathId delegate:[self sharedFactory]];
    return containerView;
}


+ (DBContainerView *)renderViewWithRenderModel:(DBRenderModel *)renderModel pathid:(NSString *)pathId{
    DBContainerView *containerView = [DBContainerViewYoga containerViewWithRenderModel:renderModel pathid:pathId delegate:[self sharedFactory]];
    return containerView;
}

//递归创建子容器
- (DBContainerView *)containerViewWithRenderModel:(DBRenderModel *)renderModel pathid:(NSString *)pathId {
    DBContainerView *subContainer = nil;
    if([renderModel.type isEqual:@"yoga"]){
        subContainer = [DBContainerViewYoga containerViewWithRenderModel:renderModel pathid:pathId delegate:self];
    } else if ([renderModel.type isEqual:@"frame"]){
        subContainer = [DBContainerViewFrame containerViewWithRenderModel:renderModel pathid:pathId delegate:self];
    }
    return subContainer;
}

@end
