//
//  UICollectionList.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/24.
//

#import "DBCollectionList.h"
#import "DBParser.h"
#import "DBImageLoader.h"
#import "DBTreeView.h"
#import "DBPool.h"
#import "Masonry.h"
#import "NSArray+DBExtends.h"
#import "UIColor+DBColor.h"

#define vhTag 100

//cell
@interface DBCollectionListCell :UICollectionViewCell
@end

@implementation DBCollectionListCell
@end

//header
@interface DBCollectionHeader :UICollectionReusableView
@end

@implementation DBCollectionHeader
@end

//footer
@interface DBCollectionFooter :UICollectionReusableView
@end

@implementation DBCollectionFooter
@end


//collectionView
@interface DBCollectionList()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectView;
@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, copy) NSArray *vh;
@property (nonatomic, strong) NSMutableArray *cellViews;
@property (nonatomic, strong) NSMutableArray *cellViews2;
@property (nonatomic, strong) DBTreeView * footer;
@property (nonatomic, strong) DBTreeView * header;
@property (nonatomic, strong) DBlistModel * listModel;
@end

@implementation DBCollectionList

#pragma mark - DBViewProtocol
-(void)onCreateView{
    [super onCreateView];
    [self createCollectionView];
    [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
}

-(void)onAttributesBind:(DBViewModel *)attributesModel{
    [super onAttributesBind:attributesModel];
    _listModel = (DBlistModel *)attributesModel;
    if(_listModel.src){
        [self handleChangeOn:_listModel.changeOn];
    }
    
    if (_listModel.vh) {
        self.vh = _listModel.vh;
    }
}

- (void)onChildrenBind:(id)view model:(DBViewModel *)model {
    [self refreshListView];
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
    DBlistModel *listModel = (DBlistModel *)self.model;
    NSString *src = [DBParser getRealValueByPathId:self.pathId andKey:listModel.src];
    if ([src isKindOfClass:[NSArray class]]) {
        self.dataList = (NSArray *)src;;
        [self.collectView reloadData];
    }
}

-(void)createCollectionView{
    DBlistModel *listModel = (DBlistModel *)self.model;
    UICollectionViewFlowLayout *flowL = [UICollectionViewFlowLayout new];
    flowL.minimumLineSpacing = 0;
    if([listModel.orientation isEqualToString:@"horizontal"]){
        [flowL setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    } else {
        [flowL setScrollDirection:UICollectionViewScrollDirectionVertical];//如果有多个区 就可以拉动
    }
    
    self.collectView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowL];
    self.collectView.delegate = self;
    self.collectView.dataSource = self;
    self.collectView.backgroundColor = [UIColor whiteColor];
    self.collectView.backgroundColor =  [UIColor db_colorWithHexString:listModel.backgroundColor];

    //注册单元格
    [self.collectView registerClass:[DBCollectionListCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectView registerClass:[DBCollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.collectView registerClass:[DBCollectionFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [self addSubview:self.collectView];
}

- (DBTreeView *)cellViewWithIndexPath:(NSIndexPath *)indexPath{
    DBTreeView *cellContentView = [self.cellViews db_ObjectAtIndex:indexPath.row];
    if(!cellContentView){
        NSDictionary *dict = self.dataList[indexPath.row];
        cellContentView = [DBTreeView treeViewWithRender:self.vh meta:dict accessKey:self.accessKey tid:@"listVh"];
        cellContentView.tag = vhTag;
        [cellContentView hiddenDebugView];
        self.cellViews[indexPath.row] = cellContentView;
    }
    return cellContentView;
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataList.count;;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DBCollectionListCell *cell = (DBCollectionListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    

    UIView *preView = [cell viewWithTag:vhTag];
    if(preView){
        [preView removeFromSuperview];
    }
    DBTreeView *cellContentView =  [self cellViewWithIndexPath:indexPath];
    [cell addSubview:cellContentView];
    [cellContentView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.left.width.equalTo(cell);
    }];
    
    [self.cellViews2 addObject:cellContentView];
    
    [cellContentView setNeedsLayout];
    [cellContentView layoutIfNeeded];
    
    if (cell.tag != 111111) {
        cell.tag = 111111;
        [self reload];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.cellViews2.count > 0 && indexPath.item < self.cellViews2.count) {
        DBTreeView *cellContentView = self.cellViews2[indexPath.item];
        return CGSizeMake(self.frame.size.width, cellContentView.bounds.size.height);
    } else{
        return  CGSizeMake(self.frame.size.width, 66);
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind ==UICollectionElementKindSectionHeader) {
        DBCollectionHeader *headerV = (DBCollectionHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"forIndexPath:indexPath];
        if(_header){
            [headerV addSubview:_header];
        }
        reusableView = headerV;
        
    }

    if (kind ==UICollectionElementKindSectionFooter){
        DBCollectionFooter *footerV = (DBCollectionFooter *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"forIndexPath:indexPath];
        if(_footer){
            [footerV addSubview:_footer];
        }
        reusableView = footerV;
    }
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DBlistModel *listModel = (DBlistModel *)self.model;
    DBTreeView *header = [DBTreeView treeViewWithRender:listModel.header meta:nil accessKey:self.accessKey tid:@"DBlistHeader"];
    if(header){
        _header = header;
        return header.bounds.size;
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    DBlistModel *listModel = (DBlistModel *)self.model;
    DBTreeView *footer = [DBTreeView treeViewWithRender:listModel.header meta:nil accessKey:self.accessKey tid:@"DBlistFooter"];
    if(footer){
        _footer = footer;
        return _footer.bounds.size;
    } else {
        return CGSizeZero;
    }
}

#pragma mark - getter/setter
- (NSMutableArray *)cellViews {
    if(!_cellViews){
        _cellViews = [[NSMutableArray alloc] initWithCapacity:self.dataList.count];
    }
    return _cellViews;
}

- (NSMutableArray *)cellViews2 {
    if(!_cellViews2){
        _cellViews2 = [[NSMutableArray alloc] init];
    }
    return _cellViews2;
}

@end
