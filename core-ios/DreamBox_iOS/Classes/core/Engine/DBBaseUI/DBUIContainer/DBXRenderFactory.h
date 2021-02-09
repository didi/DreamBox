//
//  DBRenderFactory.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import "DBXRenderModel.h"

@class DBXContainerView;
@class DBXTreeModel;

@interface DBXRenderFactory : NSObject

+ (instancetype)sharedFactory;

//treeView容器创建入口（带整体滑动的根视图）
+ (DBXContainerView *)renderViewWithTreeModel:(DBXTreeModel *)treeModel pathid:(NSString *)pathId;

//容器创建入口（flow、list等vh创建的根视图）
+ (DBXContainerView *)renderViewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId;

@end

