//
//  UICollectionList.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/24.
//

#import "DBlistView.h"
#import "DBParser.h"
#import "DBImageLoader.h"
#import "DBTreeView.h"
#import "Masonry.h"
#import "NSArray+DBExtends.h"
#import "UIColor+DBColor.h"
#import "DBContainerViewYoga.h"
#import "DBYogaModel.h"
#import "DBPool.h"
#import "DBDefines.h"
#import "UIView+Yoga.h"
#import "NSDictionary+DBExtends.h"
#import "DBRenderModel.h"
#import "DBRenderFactory.h"

#define vhTag 100

//cell
@interface DBlistViewCell :UICollectionViewCell
@end

@implementation DBlistViewCell

- (void)prepareForReuse {
    for(UIView *view in self.contentView.subviews){
        [view removeFromSuperview];
    }
};
@end

//header
@interface DBlistHeader :UICollectionReusableView
@end

@implementation DBlistHeader
@end

//footer
@interface DBlistFooter :UICollectionReusableView
@end

@implementation DBlistFooter
@end


//collectionView
@interface DBlistView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectView;
@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, strong) DBContainerViewYoga * footer;
@property (nonatomic, strong) DBContainerViewYoga * header;
@property (nonatomic, strong) DBlistModelV2* listModel;
@property (nonatomic, strong) NSMutableDictionary* containerMouldDict;
@end

@implementation DBlistView

#pragma mark - DBViewProtocol
-(void)onCreateView{
    [super onCreateView];
}

-(void)onAttributesBind:(DBViewModel *)attributesModel{
    [super onAttributesBind:attributesModel];
    _listModel = (DBlistModelV2*)attributesModel;
    [self createCollectionView];
    [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    if(_listModel.src){
        [self handleChangeOn:_listModel.changeOn];
    }
}

- (void)onChildrenBind:(id)view model:(DBViewModel *)model {
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
    DBlistModelV2*listModel = (DBlistModelV2*)self.model;
    NSString *src = [DBParser getRealValueByPathId:self.pathId andKey:listModel.src];
    if ([src isKindOfClass:[NSArray class]]) {
        self.dataList = (NSArray *)src;;
        
        CGFloat contentH = [DBDefines db_getUnit:self.model.yogaLayout.height];
        CGFloat contentW = [DBDefines db_getUnit:self.model.yogaLayout.width];
        if(!(contentW > 0)){
            contentW = [UIScreen mainScreen].bounds.size.width;
        }
        if(!(contentH > 0)){
            contentH = [UIScreen mainScreen].bounds.size.height;
        }
        
        [self setFrame:CGRectMake(0, 0, contentW, contentH)];
        
        [self.collectView reloadData];
    }
}

-(void)createCollectionView{
    DBlistModelV2*listModel = (DBlistModelV2*)self.model;
    UICollectionViewFlowLayout *flowL = [UICollectionViewFlowLayout new];
    
    if([listModel.orientation isEqualToString:@"horizontal"]){
        flowL.minimumLineSpacing = [DBDefines db_getUnit:listModel.hSpace];
        flowL.minimumInteritemSpacing = [DBDefines db_getUnit:listModel.vSpace];
        [flowL setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    } else {
        flowL.minimumLineSpacing = [DBDefines db_getUnit:listModel.vSpace];
        flowL.minimumInteritemSpacing = [DBDefines db_getUnit:listModel.hSpace];
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
    [self.collectView registerClass:[DBlistViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectView registerClass:[DBlistHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.collectView registerClass:[DBlistFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [self addSubview:self.collectView];
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
#if DEBUG
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.baidu.com"]];
#endif
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DBlistViewCell *cell = (DBlistViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    [cell prepareForReuse];

    if(!cell){
        cell = [DBlistViewCell new];
    }
    DBContainerView *contentView = [cell viewWithTag:999];
    if(!contentView){
        contentView = [self vhContentViewWithIndexPath:indexPath];
        [cell addSubview:contentView];
    } else {
        NSDictionary *dict = self.dataList[indexPath.row];
        [contentView reloadWithMetaDict:dict];
    }
    contentView.tag = 999;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    DBContainerViewYoga *cellContentView = [self vhContentViewWithIndexPath:indexPath];
    if([self.listModel.orientation isEqualToString:@"horizontal"]){
        return CGSizeMake(cellContentView.frame.size.width, self.collectView.frame.size.height);
    } else {
        return CGSizeMake(self.collectView.frame.size.width, cellContentView.frame.size.height);
    }
}

- (DBContainerViewYoga *)vhContentViewWithIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.dataList[indexPath.row];
    [[DBPool shareDBPool] setObject:dict ToDBMetaPoolWithPathId:self.pathId];
    DBRenderModel *model = [DBRenderModel modelWithDict:self.listModel.vh];
    
    DBContainerViewYoga *contentView = (DBContainerViewYoga *)[DBRenderFactory renderViewWithRenderModel:model pathid:self.pathId];
    return contentView;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind ==UICollectionElementKindSectionHeader) {
        DBlistHeader *headerV = (DBlistHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"forIndexPath:indexPath];
        if(_header){
            [headerV addSubview:_header];
        }
        reusableView = headerV;

    }

    if (kind ==UICollectionElementKindSectionFooter){
        DBlistFooter *footerV = (DBlistFooter *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"forIndexPath:indexPath];
        if(_footer){
            [footerV addSubview:_footer];
        }
        reusableView = footerV;
    }
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

    DBRenderModel *model = [DBRenderModel modelWithDict:self.header];
    DBContainerViewYoga *header = (DBContainerViewYoga *)[DBRenderFactory renderViewWithRenderModel:model pathid:self.pathId];

    if(header){
        _header = header;
        return header.bounds.size;
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    DBRenderModel *model = [DBRenderModel modelWithDict:self.footer];
    DBContainerViewYoga *footer = (DBContainerViewYoga *)[DBRenderFactory renderViewWithRenderModel:model pathid:self.pathId];
    if(footer){
        _footer = footer;
        return _footer.bounds.size;
    } else {
        return CGSizeZero;
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);//分别为上、左、下、右
}


- (NSMutableDictionary *)containerMouldDict {
    if(!_containerMouldDict){
        _containerMouldDict = [NSMutableDictionary new];
    }
    return _containerMouldDict;
}
@end
