//
//  DBContainerViewReference.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import "DBContainerViewReference.h"
#import "DBParser.h"
#import "NSArray+DBExtends.h"
#import "DBReferenceLayout.h"

@implementation DBContainerViewReference


+ (DBContainerView *)containerViewWithModel:(DBTreeModel *)model pathid:(NSString *)pathId{
    DBContainerViewReference *container = [DBContainerViewReference new];
    container.pathTid = pathId;
    container.treeModel = model;
    DBTreeModelReference *referenceModel = (DBTreeModelReference *)model;
    [container referenceLayoutWithRenderModel:model];
    [container makeContent];
    return container;
}

- (void)reloadWithDict:(NSDictionary *)dict{
    
}

- (void)referenceLayoutWithRenderModel:(DBTreeModelReference *)treeModel
{
    [self.backGroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.height.width.mas_equalTo(self);
    }];
    
    //    array
    NSArray *packedRenderArray = [self restructRenderArrayWithOriginArray:treeModel.render];
    
    for (int i = 0; i < packedRenderArray.count ; i ++) {
        NSDictionary *dict = packedRenderArray[i];
        NSString *type = [dict objectForKey:@"_type"];
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
        NSString *type = [itemDict objectForKey:@"_type"];
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
        [DBReferenceLayout layoutAllViews:model andView:(DBView*)view andRelativeViewPool:self.recyclePool];
    }
}
- (void)makeContent{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    if(self.treeModel.scroll.length > 0){
        self.scrollEnabled = YES;
        if([self.treeModel.scroll isEqualToString:@"horizontal"]){
            CGSize size = CGSizeMake([self maxXOfTreeView], [UIScreen mainScreen].bounds.size.height);
            [self setContentSize:size];
            self.backGroudView.frame = CGRectMake(self.backGroudView.frame.origin.x, self.backGroudView.frame.origin.y, size.width, size.height);
        }
        if([self.treeModel.scroll isEqualToString:@"vertical"]){
            CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [self maxYOfTreeView]);
            [self setContentSize:size];
            self.backGroudView.frame = CGRectMake(self.backGroudView.frame.origin.x, self.backGroudView.frame.origin.y, size.width, size.height);
        }
    } else {
        self.scrollEnabled = NO;
    }
}

- (CGFloat)maxXOfTreeView{
    CGFloat maxX = 0;
    for(UIView *view in self.allRenderViewArray){
        if(CGRectGetMaxX(view.frame) > maxX){
            maxX = CGRectGetMaxX(view.frame);
        }
    }
    return maxX;
}

- (CGFloat)maxYOfTreeView{
    CGFloat maxY = 0;
    for(UIView *view in self.allRenderViewArray){
        if(CGRectGetMaxY(view.frame) > maxY){
            maxY = CGRectGetMaxY(view.frame);
        }
    }
    return maxY;
}

@end
