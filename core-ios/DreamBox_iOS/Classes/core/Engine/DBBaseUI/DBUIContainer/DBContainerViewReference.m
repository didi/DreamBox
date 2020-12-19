//
//  DBContainerViewReference.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import "DBContainerViewReference.h"
#import "DBParser.h"
#import "NSArray+DBExtends.h"

@implementation DBContainerViewReference


+ (DBContainerView *)containerViewWithModel:(DBTreeModel *)model pathid:(NSString *)pathId{
    DBContainerViewReference *container = [DBContainerViewReference new];
    container.pathTid = pathId;
    DBTreeModelReference *referenceModel = (DBTreeModelReference *)model;
    [container referenceLayoutWithRenderModel:model];
    return container;
}

- (void)referenceLayoutWithRenderModel:(DBTreeModelReference *)treeModel
{
    //    array
    NSArray *packedRenderArray = [self restructRenderArrayWithOriginArray:treeModel.render];
    for (int i = 0; i < packedRenderArray.count ; i ++) {
        NSDictionary *dict = packedRenderArray[i];
        NSString *type = [dict objectForKey:@"type"];
        Class cls = [[DBFactory sharedInstance] getModelClassByType:type];
        DBViewModel *viewModel = [cls modelWithDict:dict];
        UIView *view = [self modelToView:viewModel];
        //添加到模型数组,渲染数组中
        [self addToAllContainer:self.backGroudView item:view andModel:viewModel];
    }
    [self addSubDBViewLayouts];
}

- (NSArray *)restructRenderArrayWithOriginArray:(NSArray *)itemArray{
    int k = 0;
    NSMutableArray *restructRenderArray = [[NSMutableArray alloc] initWithArray:itemArray];
    for(int i = 0; i < itemArray.count; i++){
        NSDictionary *itemDict = [itemArray db_ObjectAtIndex:i];
        NSString *type = [itemDict objectForKey:@"type"];
        if([type isEqual:@"pack"]){
            NSArray *children = [itemDict objectForKey:@"children"];
            for(NSDictionary *dict in children){
                [restructRenderArray insertObject:dict atIndex:i+k+1];
                k++;
            }
        }
    }
    return restructRenderArray;
}

//添加subview
-(void)addSubDBViewLayouts
{
    for (int i = 0; i < self.allRenderModelArray.count ;  i ++  ) {
        UIView *view = self.allRenderViewArray[i];
        if (i == 0) {
            //解析出布局
            if ([view isKindOfClass:DBView.class]) {
                DBView *dbview = (DBView *)view;
                if ([dbview.modelID isEqualToString:@"0"]) {
                    continue;
                }
            }
        }
        DBViewModel *model = self.allRenderModelArray[i];
        [DBParser layoutAllViews:model andView:(DBView*)view andRelativeViewPool:self.recyclePool];
        
    }
}


@end
