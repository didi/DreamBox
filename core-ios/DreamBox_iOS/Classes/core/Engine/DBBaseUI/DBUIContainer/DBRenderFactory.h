//
//  DBRenderFactory.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/14.
//

#import "DBRenderModel.h"

@class DBContainerView;
@class DBTreeModel;

@interface DBRenderFactory : NSObject

+ (instancetype)sharedFactory;

//treeView容器创建入口（带整体滑动的根视图）
+ (DBContainerView *)renderViewWithTreeModel:(DBTreeModel *)treeModel pathid:(NSString *)pathId;

//容器创建入口（flow、list等vh创建的根视图）
+ (DBContainerView *)renderViewWithRenderModel:(DBRenderModel *)renderModel pathid:(NSString *)pathId;

@end

