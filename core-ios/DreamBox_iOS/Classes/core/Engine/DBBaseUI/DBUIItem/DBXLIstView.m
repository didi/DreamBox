//
//  UICollectionList.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/24.
//

#import "DBXLIstView.h"
#import "DBXParser.h"
#import "DBXImageLoader.h"
#import "DBXTreeView.h"
#import <Masonry/Masonry.h>
#import "NSArray+DBXExtends.h"
#import "UIColor+DBXColor.h"
#import "DBXContainerViewYoga.h"
#import "DBXYogaModel.h"
#import "DBXPool.h"
#import "DBXDefines.h"
#import <YogaKit/UIView+Yoga.h>
#import "NSDictionary+DBXExtends.h"
#import "DBXRenderModel.h"
#import "DBXRenderFactory.h"

#define vhTag 100

//cell
@interface DBXlistViewCell :UICollectionViewCell
@end

@implementation DBXlistViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    for(UIView *view in self.contentView.subviews){
        [view removeFromSuperview];
    }
};
@end

//header
@interface DBXlistHeader :UICollectionReusableView
@end

@implementation DBXlistHeader
@end

//footer
@interface DBXlistFooter :UICollectionReusableView
@end

@implementation DBXlistFooter
@end


//collectionView
@interface DBXlistView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectView;
@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, strong) NSDictionary * footer;
@property (nonatomic, strong) NSDictionary * header;
@property (nonatomic, strong) UIView * footerView;
@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) DBXlistModelV2* listModel;
@property (nonatomic, strong) NSMutableDictionary* containerMouldDict;
@end

@implementation DBXlistView

#pragma mark - DBXViewProtocol
-(void)onCreateView{
    [super onCreateView];
}

-(void)onAttributesBind:(DBXViewModel *)attributesModel{
    [super onAttributesBind:attributesModel];
    _listModel = (DBXlistModelV2*)attributesModel;
    [self createCollectionView];
    [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    if(_listModel.src){
        [self handleChangeOn:_listModel.changeOn];
    }
}

- (void)onChildrenBind:(id)view model:(DBXViewModel *)model {
    [self refreshListView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

-(CGSize)wrapSize {
    return CGSizeZero;
}

#pragma mark - inherited
- (void)reload {
    [self refreshListView];
}

#pragma mark - privateMethods
- (void)refreshListView{
    DBXlistModelV2*listModel = (DBXlistModelV2*)self.model;
    NSString *src = [DBXParser getRealValueByPathId:self.pathId andKey:listModel.src];
    if ([src isKindOfClass:[NSArray class]]) {
        self.dataList = (NSArray *)src;
        
        CGFloat contentH = [DBXDefines db_getUnit:self.model.yogaLayout.height pathId:self.pathId];
        CGFloat contentW = [DBXDefines db_getUnit:self.model.yogaLayout.width pathId:self.pathId];
//        if(!(contentW > 0)){
//            contentW = [UIScreen mainScreen].bounds.size.width;
//        }
//        if(!(contentH > 0)){
//            contentH = [UIScreen mainScreen].bounds.size.height;
//        }
//
        [self setFrame:CGRectMake(0, 0, contentW, contentH)];
        
        [self.collectView reloadData];
    }
}

-(void)createCollectionView{
    DBXlistModelV2*listModel = (DBXlistModelV2*)self.model;
    UICollectionViewFlowLayout *flowL = [UICollectionViewFlowLayout new];
    
    if([listModel.orientation isEqualToString:@"horizontal"]){
        flowL.minimumLineSpacing = [DBXDefines db_getUnit:listModel.hSpace pathId:self.pathId];
        flowL.minimumInteritemSpacing = [DBXDefines db_getUnit:listModel.vSpace pathId:self.pathId];
        [flowL setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    } else {
        flowL.minimumLineSpacing = [DBXDefines db_getUnit:listModel.vSpace pathId:self.pathId];
        flowL.minimumInteritemSpacing = [DBXDefines db_getUnit:listModel.hSpace pathId:self.pathId];
        [flowL setScrollDirection:UICollectionViewScrollDirectionVertical];//如果有多个区 就可以拉动
    }

    
    
    self.collectView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowL];
    self.collectView.delegate = self;
    self.collectView.dataSource = self;
    self.collectView.backgroundColor = [UIColor whiteColor];
    self.collectView.backgroundColor =  [UIColor db_colorWithHexString:listModel.backgroundColor];
    self.collectView.showsVerticalScrollIndicator = NO;
    self.collectView.showsHorizontalScrollIndicator = NO;
    
    //注册单元格
    [self.collectView registerClass:[DBXlistViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectView registerClass:[DBXlistHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.collectView registerClass:[DBXlistFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [self addSubview:self.collectView];
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    CGFloat top = 0;
    CGFloat left = 0;
    CGFloat bottom = 0;
    CGFloat right = 0;
    
    if([self.listModel.orientation isEqualToString:@"horizontal"]){
        left = [DBXDefines db_getUnit:self.listModel.edgeStart pathId:self.pathId];
        right = [DBXDefines db_getUnit:self.listModel.edgeEnd pathId:self.pathId];
    } else {
        top = [DBXDefines db_getUnit:self.listModel.edgeStart pathId:self.pathId];
        bottom = [DBXDefines db_getUnit:self.listModel.edgeEnd pathId:self.pathId];
    }
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DBXlistViewCell *cell = (DBXlistViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    [cell prepareForReuse];

    if(!cell){
        cell = [DBXlistViewCell new];
    }
    DBXContainerView *contentView = [cell viewWithTag:999];
    if(contentView){
        [contentView removeFromSuperview];
        contentView = nil;
    }
    contentView = [self vhContentViewWithIndexPath:indexPath];
    [cell addSubview:contentView];
    contentView.tag = 999;
    NSDictionary *dict = self.dataList[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dbxViewExposureWithParam:)]) {
        [self.delegate dbxViewExposureWithParam:dict];
    }
    
    return cell;
}

- (void)setDelegate:(id<DBXViewDelegate>)delegate {
    _delegate = delegate;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    DBXContainerViewYoga *cellContentView = [self vhContentViewWithIndexPath:indexPath];
    if([self.listModel.orientation isEqualToString:@"horizontal"]){
        return CGSizeMake(cellContentView.frame.size.width, self.collectView.frame.size.height);
    } else {
        return CGSizeMake(self.collectView.frame.size.width, cellContentView.frame.size.height);
    }
}

- (DBXContainerViewYoga *)vhContentViewWithIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.dataList[indexPath.row];
    [[DBXPool shareDBPool] setObject:dict ToDBMetaPoolWithPathId:[NSString stringWithFormat:@"%@&%ld",self.pathId, indexPath.row]];
    DBXRenderModel *model = [DBXRenderModel modelWithDict:self.listModel.vh];
    
    DBXContainerViewYoga *contentView = (DBXContainerViewYoga *)[DBXRenderFactory renderViewWithRenderModel:model pathid:[NSString stringWithFormat:@"%@&%ld",self.pathId, indexPath.row]];
//    [[DBXPool shareDBPool] removeObjectFromMetaPoolWithPathId:[NSString stringWithFormat:@"%@&%ld",self.pathId, indexPath.row]];
    return contentView;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind ==UICollectionElementKindSectionHeader) {
        DBXlistHeader *headerV = (DBXlistHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"forIndexPath:indexPath];
        if(_headerView){
            [headerV addSubview:_headerView];
        }
        reusableView = headerV;

    }

    if (kind ==UICollectionElementKindSectionFooter){
        DBXlistFooter *footerV = (DBXlistFooter *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"forIndexPath:indexPath];
        if(_footerView){
            [footerV addSubview:_footerView];
        }
        reusableView = footerV;
    }
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

    DBXRenderModel *model = [DBXRenderModel modelWithDict:self.listModel.header];
    DBXContainerViewYoga *header = (DBXContainerViewYoga *)[DBXRenderFactory renderViewWithRenderModel:model pathid:self.pathId];

    if(header){
        _headerView = header;
        return header.bounds.size;
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    DBXRenderModel *model = [DBXRenderModel modelWithDict:self.listModel.footer];
    DBXContainerViewYoga *footer = (DBXContainerViewYoga *)[DBXRenderFactory renderViewWithRenderModel:model pathid:self.pathId];
    if(footer){
        _footerView = footer;
        return footer.bounds.size;
    } else {
        return CGSizeZero;
    }
}

- (NSMutableDictionary *)containerMouldDict {
    if(!_containerMouldDict){
        _containerMouldDict = [NSMutableDictionary new];
    }
    return _containerMouldDict;
}
@end
