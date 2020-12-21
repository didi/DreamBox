//
//  DBFlowView.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/27.
//

#import "DBFlowView.h"
#import "DBViewModel.h"
#import "DBParser.h"
#import "DBDefines.h"
#import "Masonry.h"
#import "NSArray+DBExtends.h"
#import "NSDictionary+DBExtends.h"
#import "DBContainerViewYoga.h"
#import "DBYogaModel.h"
#import "DBPool.h"
#import "UIView+Yoga.h"

@interface DBFlowView()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, strong)NSMutableArray *itemViews;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation DBFlowView

#pragma mark - lideCycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [UIView new];
        [self addSubview:_contentView];
    }
    return self;
}

#pragma mark - DBViewProtocol
- (void)setDataWithModel:(DBFlowModel *)flowModel andPathId:(NSString *)pathId {
    [super setDataWithModel:flowModel andPathId:pathId];
    
    if(flowModel.src){
        [self handleChangeOn:flowModel.changeOn];
    }

    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.equalTo(self);
    }];
    
    [self refreshFlow];
}

#pragma mark - inherited
- (void)reload {
    //刷内容
    [self refreshFlow];
    //刷size
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.contentSize);
    }];
}

#pragma mark - privateMethods
- (void)refreshFlow{
    DBFlowModel *model = (DBFlowModel *)self.model;
    NSString *src = [DBParser getRealValueByPathId:self.pathId andKey:model.src];
    if ([src isKindOfClass:[NSArray class]]) {
        NSArray *srcArr = (NSArray *)src;
        self.dataList = srcArr;
        [self creatUI];
    }
}

- (void)creatUI{
    [self removeAllItems];
    DBFlowModel *flowModel = (DBFlowModel *)self.model;
    CGFloat contentW = 0;
    NSString *contentWStr = self.model.yogaLayout.width ? self.model.yogaLayout.width : self.model.yogaLayout.maxWidth;
    contentW = [DBDefines db_getUnit:contentWStr];
    if(!(contentW > 0)){
        contentW = [UIScreen mainScreen].bounds.size.width;
    }
    
    CGFloat vSpace = [DBDefines db_getUnit:flowModel.vSpace];
    CGFloat hSpace = [DBDefines db_getUnit:flowModel.hSpace];
    
    [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.justifyContent = YGJustifyFlexStart;
        layout.flexWrap = YGWrapWrap;
        layout.width = YGPointValue(contentW);
    }];
    
    for(int i = 0; i < self.dataList.count; i++){
        NSDictionary *dict = [self.dataList db_ObjectAtIndex:i];
        [[DBPool shareDBPool] setObject:dict ToDBMetaPoolWithPathId:self.pathId];
        NSDictionary *itemDict = [self.model.children db_ObjectAtIndex:0];
        DBYogaRenderModel *model = [DBYogaRenderModel modelWithDict:itemDict];
        UIView *itemView;
        if([model.type isEqual:@"yoga"]){
            itemView = [DBContainerViewYoga containerViewWithYogaModel:model pathid:self.pathId];
        } else {
            //扩展其他布局类型
            itemView = [UIView new];
            itemView.backgroundColor = [UIColor greenColor];
            itemView.frame = CGRectMake(0, 0, 50, 50);
        }
        
        [_contentView addSubview:itemView];
        [itemView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isEnabled = YES;
            layout.width = YGPointValue(itemView.frame.size.width);
            layout.height = YGPointValue(itemView.frame.size.height);
            layout.marginTop = YGPointValue(vSpace);
            layout.marginBottom = YGPointValue(vSpace);
            layout.marginLeft = YGPointValue(hSpace);
            layout.marginRight = YGPointValue(hSpace);
        }];
    }
    [self.contentView.yoga applyLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
}

- (void)removeAllItems{
    for(UIView *view in self.itemViews){
        [view removeFromSuperview];
    }
    [self.itemViews removeAllObjects];
}

#pragma mark - getter/setter
- (NSMutableArray *)itemViews {
    if(!_itemViews){
        _itemViews = [[NSMutableArray alloc] initWithCapacity:self.dataList.count];
    }
    return _itemViews;
}

//- (CGSize)wrapSize {
//    return self.contentSize;
//}

//- (void)creatUI{
//    [self removeAllItems];
//    DBFlowModel *flowModel = (DBFlowModel *)self.model;
//    DBContainerViewYoga *lastItemView;
//
//    CGFloat x = 0;
//    CGFloat y = 0;
//    CGFloat maxW = 0;
//    CGFloat maxH = 0;
//    CGFloat itemH = 0;
//    CGFloat vSpace = [DBDefines db_getUnit:flowModel.vSpace];
//    CGFloat hSpace = [DBDefines db_getUnit:flowModel.hSpace];;
//
//    for(int i = 0; i < self.dataList.count; i++){
//        NSDictionary *dict = [self.dataList db_ObjectAtIndex:i];
//        DBContainerViewYoga *itemView = [self.itemViews db_ObjectAtIndex:i];
//        if(!itemView){
//            NSDictionary *itemDict = [self.model.children db_ObjectAtIndex:0];
//            DBYogaRenderModel *model = [DBYogaRenderModel modelWithDict:itemDict];
//            [[DBPool shareDBPool] setObject:dict ToDBMetaPoolWithPathId:self.pathId];
//            itemView = [DBContainerViewYoga containerViewWithYogaModel:model pathid:self.pathId];
//
////            [itemView hiddenDebugView];
//        }
//        [_contentView addSubview:itemView];
//        CGSize itemSize = itemView.frame.size;
//        itemH = itemSize.height;
//        [self.itemViews addObject:itemView];
//
//        //item宽不得超过一行
//
//        if(itemSize.width + hSpace > [UIScreen mainScreen].bounds.size.width){
//            if(lastItemView && (x != 0)){
//                y += (vSpace + lastItemView.frame.size.height);
//            }
//            itemSize.width = [UIScreen mainScreen].bounds.size.width - hSpace;
//            [self layoutTargetView:itemView withRect:CGRectMake(0, y, itemSize.width, itemSize.height)];
//            x = 0;
//            y += (vSpace + itemSize.height);
//            lastItemView = itemView;
//            continue;
//        }
//
//
//        if(x + hSpace + itemSize.width < [UIScreen mainScreen].bounds.size.width){
//            [self layoutTargetView:itemView withRect:CGRectMake(x, y, itemSize.width, itemSize.height)];
//            x += (hSpace + itemSize.width);
//            if(maxW < x){
//                maxW = x;
//            }
//        } else {
//            x = 0;
//            y += (vSpace + itemSize.height);
//            [self layoutTargetView:itemView withRect:CGRectMake(x, y, itemSize.width, itemSize.height)];
//            x += (hSpace + itemSize.width);
//        }
//        lastItemView = itemView;
//    }
//    maxH = y + itemH;
//    self.frame = CGRectMake(0, 0, maxW, maxH);
//}

//- (void)layoutTargetView:(UIView *)targetView withRect:(CGRect)rect{
//    UIView *referenceView = targetView.superview;
//    [targetView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(referenceView).offset(rect.origin.y);
//        make.left.mas_equalTo(referenceView).offset(rect.origin.x);
//        make.width.mas_equalTo(rect.size.width);
//        make.height.mas_equalTo(rect.size.height);
//    }];
//}



@end
