//
//  DBView.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBTreeView.h"
#import "DBView.h"

#import "DBText.h"
#import "DBProgress.h"
#import "DBImage.h"
#import "DBParser.h"
#import "DBViewModel.h"
#import "DBService.h"
#import "UIColor+DBColor.h"
#import "UIView+DBStrike.h"
#import "DBHelper.h"
#import "DBPreProcess.h"
#import "DBParser.h"
#import "DBViewProtocol.h"
#import "DBRecyclePool.h"
#import "DBService.h"
#import "DBWrapperManager.h"
#import "DBFactory.h"
#import "NSDictionary+DBExtends.h"
#import "DBDeugSignView.h"
#import "Masonry.h"
#import "DBCallBack.h"
#import "NSArray+DBExtends.h"
#import "UIView+Yoga.h"
#import "DBFlexBoxLayout.h"
#import "DBDefines.h"

static NSString *const kDBMetaExtKey = @"ext";
static NSString *const kDBMetaPoolKey = @"pool";


typedef void(^DBAliasBlock)(NSDictionary *src);

@interface DBTreeView ()

@property (nonatomic ,copy, readwrite) NSString *accessKey;
@property (nonatomic, strong) NSDictionary*extData;
@property (nonatomic, copy) NSString *tid; //模版id
@property (nonatomic, copy) NSString *pathTid; //模版id

@property (nonatomic, strong) DBTreeModel *treeModel;
@property (nonatomic, strong) NSMutableArray *allRenderViewArray;
@property (nonatomic, strong) NSMutableArray *allRenderModelArray;
@property (nonatomic, strong) NSMutableDictionary *aliasDict;
@property (nonatomic, strong) NSMutableDictionary *metaDict;
@property (nonatomic, strong) UIScrollView *bgView;
@property (nonatomic, strong) DBView *backGroudView;
@property (nonatomic, strong) DBRecyclePool *recyclePool;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, strong) NSMutableDictionary *changeOnDict;
@property (nonatomic, strong) NSMutableDictionary *eventDictD2N;
@property (nonatomic, strong) NSMutableDictionary *eventDictN2D;

@property (nonatomic, strong) DBDeugSignView *debugIcon;
@end

@implementation DBTreeView
#pragma mark - Public
- (void)dealloc{
    [self handleDismissOn:self.treeModel.changeOn];
}

- (void)loadWithTemplateId:(NSString *)tid accessKey:(NSString *)accessKey extData:(nonnull NSDictionary *)ext completionBlock:(DBTreeRenderBlock)completionBlock {
    
    self.accessKey = accessKey;
    self.tid = tid;
    [self p_debugView];
    
    NSTimeInterval tStart = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);//毫秒，精确到个位
    
    [[DBWrapperManager sharedManager] getDataByTemplateId:tid accessKey:accessKey completionBlock:^(NSError * _Nullable error, NSString * _Nullable data) {
        NSTimeInterval tGetTem = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);//毫秒，精确到个位
        if (!error) {
            DBProcesssModel *process = [DBPreProcess preProcess:data];
            //判断是否有map
            if ([process.data db_objectForKey:@"map"]) {
                process.data = [DBParser parseOriginDict:[process.data  db_objectForKey:@"dbl"] withMap:[process.data db_objectForKey:@"map"]];
            }
            if (process && process.data) {
                NSDictionary *dict = process.data;
                DBTreeModel *treeModel = [DBParser parserDict:dict];
                if (treeModel) {
                    NSString *pathId = [self pathIdWithTid:self.tid ? self.tid : [[DBPool shareDBPool] getAutoIncrementTid] accessKey:self.accessKey];
                    [self p_buildWithTreeModel:treeModel extMeta:ext pathId:pathId];
                    
                    NSTimeInterval tEnd = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);//毫秒，精确到个位
                    NSDictionary *para = @{@"duration":@(tEnd-tStart).stringValue,
                                           @"get_temp_time":@(tGetTem - tStart).stringValue};
                    
                    [[DBWrapperManager sharedManager] reportTid:tid Key:@"tech_duration_render_total" accessKey:accessKey params:para frequency:DBReportFrequencySAMPLE];
                    [self trace_parser_template:dict andLength:@(data.length).stringValue andDuration:@(tEnd-tStart).stringValue];
                    
                    if (completionBlock) {
                        [[DBWrapperManager sharedManager] reportTid:tid Key:@"tech_duration_render_result" accessKey:accessKey params:@{@"success":@(1).stringValue} frequency:DBReportFrequencyEVERY];
                        completionBlock(YES,nil);
                    }
                }
            } else {
                if (completionBlock) {
                    
                    NSError *error = [NSError errorWithDomain:@"DB" code:102 userInfo:@{NSLocalizedDescriptionKey:@"模板解密失败"}];
                    [[DBWrapperManager sharedManager] reportTid:tid Key:@"tech_duration_render_result" accessKey:accessKey params:@{@"success":@"0",@"reason":@"模板解密失败",} frequency:DBReportFrequencyEVERY];
                    completionBlock(NO,error);
                }
            }
        } else {
            if (completionBlock) {
                [[DBWrapperManager sharedManager] reportTid:tid Key:@"tech_duration_render_result" accessKey:accessKey params:@{@"success":@"0",@"reason":error.localizedDescription} frequency:DBReportFrequencyEVERY];
                completionBlock(NO,error);
            }
        }
    }];
    
}

- (DBTreeView *)initWithData:(NSString *)data extMeta:(nonnull NSDictionary *)ext accessKey:(nonnull NSString *)accessKey tid:(NSString *)tid{
    self.accessKey = accessKey;
    self.tid = tid;
    self = [super init];
    if (self) {
        // 预处理
        DBProcesssModel *process = [DBPreProcess preProcess:data];
        if (process && process.data) {
            NSDictionary *dict = process.data;
            DBTreeModel *treeModel = [DBParser parserDict:dict];
            if (treeModel) {
                NSString *pathId = [self pathIdWithTid:self.tid ? self.tid : [[DBPool shareDBPool] getAutoIncrementTid] accessKey:self.accessKey];
                [self p_buildWithTreeModel:treeModel extMeta:ext pathId:pathId];
            }
        }
    }
    return self;
}

- (DBTreeView *)initWithJsonSting:(NSString *)jsonString extMeta:(NSDictionary *)ext accessKey:(NSString *)accessKey tid:(NSString *)tid{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (!dict) {
        NSLog(@"解析jsonsting失败");
        return nil;
    }
    
    if ([dict objectForKey:@"map"]) {
        dict = [DBParser parseOriginDict:[dict objectForKey:@"dbl"] withMap:[dict objectForKey:@"map"]];
    }
    
    return [self initWithDict:[dict mutableCopy] extMeta:ext accessKey:accessKey tid:tid];
}


- (DBTreeView *)initWithDict:(NSDictionary *)treeDict extMeta:(NSDictionary *)ext accessKey:(NSString *)accessKey tid:(NSString *)tid{
    DBTreeModel *treeModel = [DBParser parserDict:treeDict];
    return [self initWithModel:treeModel extMeta:ext accessKey:accessKey tid:tid];
}

- (DBTreeView *)initWithModel:(DBTreeModel *)treeModel extMeta:(nonnull NSDictionary *)ext accessKey:(nonnull NSString *)accessKey tid:(NSString *)tid
{
    self.accessKey = accessKey;
    self.tid = tid;
    self = [super init];
    if (self) {
        NSString *pathId = [self pathIdWithTid:self.tid ? self.tid : [[DBPool shareDBPool] getAutoIncrementTid] accessKey:self.accessKey];
        [self p_buildWithTreeModel:treeModel extMeta:ext pathId:pathId];
    }
    return self;
}
// reload方法，for catalog
- (void)reloadWithData:(NSString *)data extMeta:(NSDictionary *)ext {
    // 预处理
    DBProcesssModel *process = [DBPreProcess preProcess:data];
    if (process && process.data) {
        NSDictionary *dict = process.data;
        DBTreeModel *treeModel = [DBParser parserDict:dict];
        if (treeModel) {
            
            for (UIView *view in self.allRenderViewArray) {
                if ([view isKindOfClass:DBView.class]) {
                    DBView *dbview = (DBView *)view;
                    if ([dbview.modelID isEqualToString:@"0"]) {
                        continue;
                    }
                }
                if ([view isKindOfClass:UIView.class]) {
                    [view removeFromSuperview];
                }
            }
            [self.allRenderViewArray removeAllObjects];
            [self.allRenderModelArray removeAllObjects];
            NSString *pathId = [self pathIdWithTid:self.tid ? self.tid : [[DBPool shareDBPool] getAutoIncrementTid] accessKey:self.accessKey];
            [self p_buildWithTreeModel:treeModel extMeta:ext pathId:pathId];
        }
    }
}

- (void)bindExtensionMetaData:(NSDictionary *)ext {
    
    [self p_bindExtensionMetaData:ext];
    [[DBPool shareDBPool] setObject:ext ToDBExtPoolWithPathId:self.pathTid];
    [self reloadTreeView];
}

- (void)updatePoolMetaData:(NSDictionary *)entries {
    
    if (![DBValidJudge isValidDictionary:entries]) {
        return;
    }
    if (![DBValidJudge isValidDictionary:self.metaDict]) {
        self.metaDict = [NSMutableDictionary dictionary];
    }
    if (![self p_isValidMetaPoolData]) {
        [self.metaDict db_setValue:entries forKey:kDBMetaPoolKey];
    } else {
        NSDictionary *poolDict = [self.metaDict objectForKey:kDBMetaPoolKey];
        NSMutableDictionary *newPool = [NSMutableDictionary dictionaryWithDictionary:poolDict];
        [newPool addEntriesFromDictionary:entries];
        [self.metaDict db_setValue:newPool forKey:kDBMetaPoolKey];
    }
    [[DBPool shareDBPool] setObject:entries ToDBMetaPoolWithPathId:self.pathTid];
}
- (void)updatePoolMetaKey:(NSString *)key value:(NSString *)value {
    if (![DBValidJudge isValidString:key] || ![DBValidJudge isValidString:value]) {
        return;
    }
    
    NSMutableDictionary *entries = [NSMutableDictionary dictionary];
    [entries db_setValue:value forKey:key];
    [self updatePoolMetaData:entries];
    
}
#pragma mark -
- (void)p_buildWithTreeModel:(DBTreeModel *)treeModel extMeta:(NSDictionary *)ext pathId:(NSString *)pathId{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    if (!treeModel) {
        return;
    }
    
    self.modelID = @"0";
    if (!self.tid) {
        self.tid = @"0";
    }
    self.extData = ext;
    self.pathTid = pathId;
    self.maxHeight = 0 ;
    self.treeModel = treeModel;
    [self setCurrentData:treeModel.meta];
    [self p_bindExtensionMetaData:ext];
    
    //    [self p_debugView];
    
    //Meta ext accesskey 存储进数据池
    if (self.accessKey != nil && ![treeModel.isSubTree isEqualToString:@"1"]) {
        [[DBPool shareDBPool] setAllAccessKeyAndTidDict:self.accessKey andTid:self.tid];
    }
    //添加到dbpool:pathId与accessKey对应关系
    [[DBPool shareDBPool] setAccessKey:self.accessKey ToSearchAccessPoolWithPathId:self.pathTid];
    [[DBPool shareDBPool] setTid:self.tid ToSearchTidPoolWithPathId:self.pathId];
    //添加到dbpool的treeView池
    [[DBPool shareDBPool] setObject:self toViewMapTableWithPathId:self.pathTid];
    //添加到dbpool的meta池
    [[DBPool shareDBPool] setObject:treeModel.meta ToDBMetaPoolWithPathId:self.pathTid];
    //添加到dbpool的ext池
    [[DBPool shareDBPool] setObject:ext ToDBExtPoolWithPathId:self.pathTid];
    
    
    //    [self handleOnVisible:treeModel.onVisible];
    //    [self handleOnInVisible:treeModel.onInvisible];
    
    //绑定回调事件
    self.callBacks = treeModel.callbacks;
    [DBCallBack bindView:self withCallBacks:self.callBacks];
    
    [self regiterOnEvent:treeModel.onEvent];
    [self handleChangeOn:treeModel.changeOn];
    [self circulationAliasDict:treeModel.actionAlias];
    [self makeContent];
    NSInteger dbVersion = 4;
    if(dbVersion >= 4){
        [self flexBoxcirCulationRender:treeModel];
    } else {
        [self circulationRenderArray:treeModel.render];
    }
    
    
    }

- (NSString *)pathIdWithTid:(NSString *)tid accessKey:(NSString *)accessKey {
    return [accessKey stringByAppendingString:tid];
}

- (void)makeContent{
    if(self.treeModel.scroll.length > 0){
        [self setNeedsLayout];
        [self layoutIfNeeded];
        self.bgView.scrollEnabled = YES;
        if([self.treeModel.scroll isEqualToString:@"horizontal"]){
            CGSize size = CGSizeMake([self maxXOfTreeView], [UIScreen mainScreen].bounds.size.height);
            [self.bgView setContentSize:size];
            self.backGroudView.frame = CGRectMake(self.backGroudView.frame.origin.x, self.backGroudView.frame.origin.y, size.width, size.height);
        }
        if([self.treeModel.scroll isEqualToString:@"vertical"]){
            CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [self maxYOfTreeView]);
            [self.bgView setContentSize:size];
            self.backGroudView.frame = CGRectMake(self.backGroudView.frame.origin.x, self.backGroudView.frame.origin.y, size.width, size.height);
        }
    } else {
        self.bgView.scrollEnabled = NO;
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


//+ (DBTreeView *)treeViewWithRender:(NSArray *)renderArray andTid:(NSString *)tid andMeta:(NSDictionary *)metaDict dataKeyPath:(NSString *)dataKeyPath
+ (DBTreeView *)treeViewWithRender:(NSArray *)renderArray meta:(NSDictionary *)metaDict accessKey:(NSString *)accessKey tid:(NSString *)tid;
{
    //    NSDictionary *ext = [[DBPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId];
    NSMutableDictionary *treeDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *dblDict = [NSMutableDictionary dictionary];
    dblDict[@"render"] = renderArray;
    if (metaDict) {
        dblDict[@"meta"] = metaDict;
    }
    treeDict[@"dbl"] = dblDict;
    treeDict[@"isSubTree"] = @"1";
    DBTreeView *treeView = [[DBTreeView alloc] initWithDict:treeDict extMeta:nil accessKey:accessKey tid:tid];
    [treeView setNeedsLayout];
    [treeView layoutIfNeeded];
    return treeView;
}

//- (CGSize)sizeWithRenderArray:(NSArray *)renderArr andTid:(NSString *)tid{
//    CGFloat maxW = 0;
//    CGFloat maxH = 0;
//
////    for(uivi)
//
//}

+ (DBTreeView *)treeViewWithRender:(NSArray *)renderArray accessKey:(NSString *)accessKey tid:(NSString *)tid
{
    //    NSDictionary *ext = [[DBPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId];
    NSMutableDictionary *treeDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *dblDict = [NSMutableDictionary dictionary];
    dblDict[@"render"] = renderArray;
    treeDict[@"dbl"] = dblDict;
    treeDict[@"isSubTree"] = @"1";
    DBTreeView *treeView = [[DBTreeView alloc] initWithDict:treeDict extMeta:nil accessKey:accessKey tid:tid];
    [treeView setNeedsLayout];
    [treeView layoutIfNeeded];
    return treeView;
}


- (void)p_bindExtensionMetaData:(NSDictionary *)ext {
    
    if (![DBValidJudge isValidDictionary:ext]) {
        return;
    }
    if (![DBValidJudge isValidDictionary:self.metaDict]) {
        self.metaDict = [NSMutableDictionary dictionary];
    }
    [self.metaDict db_setValue:ext forKey:kDBMetaExtKey];
    
    //添加到dbpool的ext池
    [[DBPool shareDBPool] setObject:ext ToDBExtPoolWithPathId:self.pathTid];
}

- (BOOL)p_isValidMetaPoolData {
    
    if (![DBValidJudge isValidDictionary:self.metaDict]) {
        self.metaDict = [NSMutableDictionary dictionary];
    }
    NSDictionary *poolData = [self.metaDict objectForKey:kDBMetaPoolKey];
    return [DBValidJudge isValidDictionary:poolData];
}


//数组遍历render节点执行
- (void)circulationRenderArray:(NSArray *)itemArrays
{
    //    array
    NSArray *packedRenderArray = [self restructRenderArrayWithOriginArray:itemArrays];
    for (int i = 0; i < packedRenderArray.count ; i ++) {
        NSDictionary *dict = packedRenderArray[i];
        NSString *type = [dict objectForKey:@"type"];
        Class cls = [[DBFactory sharedInstance] getModelClassByType:type];
        DBViewModel *viewModel = [cls modelWithDict:dict];
        UIView *view = [self modelToView:viewModel];
        //添加到模型数组,渲染数组中
        [self addToAllContainersView:view andModel:viewModel];
    }
    [self addSubDBViewLayouts];
}

- (void)flexBoxcirCulationRender:(DBTreeModel *)treeModel
{
    [DBParser flexLayoutView:self.backGroudView withModel:treeModel];
    self.backGroudView.backgroundColor = [UIColor grayColor];
    //    array
    NSArray *renderArray = treeModel.render;
    for (int i = 0; i < renderArray.count ; i ++) {
        NSDictionary *dict = renderArray[i];
        NSString *type = [dict objectForKey:@"type"];
        Class cls = [[DBFactory sharedInstance] getModelClassByType:type];
        DBViewModel *viewModel = [cls modelWithDict:dict];
        UIView *view = [self modelToView:viewModel];
        //添加到模型数组,渲染数组中
        [self addToAllContainersView:view andModel:viewModel];
        [DBParser flexLayoutView:view withModel:viewModel];
//        view.backgroundColor = [UIColor clearColor];
    }
    [self.backGroudView.yoga applyLayoutPreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
}

- (void)flexBoxcirCulationRender2:(DBTreeModel *)treeModel
{
    [DBParser flexLayoutView:self.backGroudView withModel:treeModel];
    self.backGroudView.backgroundColor = [UIColor grayColor];
    //    array
    NSArray *renderArray = treeModel.render;
    for (int i = 0; i < renderArray.count ; i ++) {
        NSDictionary *dict = renderArray[i];
        NSString *type = [dict objectForKey:@"type"];
        Class cls = [[DBFactory sharedInstance] getModelClassByType:type];
        DBViewModel *viewModel = [cls modelWithDict:dict];
        UIView *view = [self modelToView:viewModel];
        //添加到模型数组,渲染数组中
        [self addToAllContainersView:view andModel:viewModel];
        [DBParser flexLayoutView:view withModel:viewModel];
        view.backgroundColor = [UIColor clearColor];
    }
    [DBParser applyLayoutToView:self.backGroudView rreservingOrigin:YES dimensionFlexibility:YGDimensionFlexibilityFlexibleWidth | YGDimensionFlexibilityFlexibleHeight];
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



-(void)addToAllContainersView:(UIView *)view andModel:(DBViewModel *)viewModel
{
    if (!view || !viewModel) {
        return;
    }
    [self.allRenderViewArray addObject:view];
    [self.allRenderModelArray addObject:viewModel];
    [self.backGroudView addSubview:view];
    if (viewModel.modelID) {
        [self.recyclePool setItem:view withIdentifier:viewModel.modelID];
    }
}

-(void)setCurrentData:(NSDictionary *)metaDict
{
    if (!metaDict || ![metaDict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.metaDict = [metaDict mutableCopy];
}

//模型到DBView
- (DBView *)modelToView:(DBViewModel *)model
{
    //解析出view
    DBView *view = [DBParser modelToView:model andPathId:self.pathTid];
    return view;
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



-(CGFloat)getTreeViewHeight
{
    [self layoutIfNeeded];
    for (int i = 0; i < self.allRenderModelArray.count ; i ++ ) {
        //解析出布局
        UIView *view = self.allRenderViewArray[i];
        //遍历view返回整个treeView最大高度
        if (self.maxHeight < CGRectGetMaxY(view.frame)) {
            self.maxHeight = CGRectGetMaxY(view.frame);
        }
    }
    return self.maxHeight;
}

//lazy
-(NSMutableDictionary *)changeOnDict
{
    if (_changeOnDict == nil) {
        _changeOnDict = [NSMutableDictionary dictionary];
    }
    return _changeOnDict;
}

-(NSMutableArray *)allRenderViewArray
{
    if (_allRenderViewArray == nil) {
        _allRenderViewArray = [NSMutableArray array];
        self.backGroudView.modelID = @"0";
        [_allRenderViewArray addObject:self.backGroudView];
    }
    return _allRenderViewArray;
}

-(NSMutableArray *)allRenderModelArray
{
    if (_allRenderModelArray == nil) {
        _allRenderModelArray = [NSMutableArray array];
        DBViewModel *model = [DBViewModel new];
        model.modelID = @"0";
        [_allRenderModelArray addObject:model];
    }
    return _allRenderModelArray;
}

- (NSMutableDictionary *)aliasDict {
    if (!_aliasDict) {
        _aliasDict = [[NSMutableDictionary alloc] init];
    }
    return _aliasDict;
    
}

-(DBView *)backGroudView{
    if (!_backGroudView) {
        _backGroudView = [[DBView alloc] init];
        [self.bgView addSubview:_backGroudView];
        int dbVersion = 4;
        if(dbVersion >= 4){
            
        } else {
            [_backGroudView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.height.width.mas_equalTo(self.bgView);
            }];
        }
    }
    return _backGroudView;
}

- (UIScrollView *)bgView {
    if(!_bgView){
        _bgView = [UIScrollView new];
        if (@available(iOS 11.0, *)) {
            _bgView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:_bgView];
        //        _bgView.translatesAutoresizingMaskIntoConstraints = NO;
        //        NSLayoutConstraint *leftConstraint1 = [NSLayoutConstraint constraintWithItem:_bgView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        //        NSLayoutConstraint *topConstraint1 = [NSLayoutConstraint constraintWithItem:_bgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        //        NSLayoutConstraint *widthConstraint1 = [NSLayoutConstraint constraintWithItem:_bgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        //        NSLayoutConstraint *heightConstraint1 = [NSLayoutConstraint constraintWithItem:_bgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        //        leftConstraint1.active = YES;
        //        topConstraint1.active = YES;
        //        widthConstraint1.active = YES;
        //        heightConstraint1.active = YES;
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.height.equalTo(self);
        }];
    }
    return _bgView;
}

//复用池
-(DBRecyclePool *)recyclePool
{
    if (!_recyclePool) {
        _recyclePool = [DBRecyclePool new];
        self.backGroudView.modelID = @"0";
        [_recyclePool setItem:self.backGroudView withIdentifier:self.backGroudView.modelID];
    }
    return _recyclePool;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"keyPath=%@,object=%@,change=%@,context=%@",keyPath,object,change,context);
    //有数据变化,刷新
    //    [self reloadTreeView];
}

#pragma lifeCircle

//添加bridge事件监听
-(void)regiterOnEvent:(NSDictionary *)onEventDict {
    if(onEventDict){
        NSString *eid = [onEventDict db_objectForKey:@"eid"];
        if(eid.length > 0){
            [self.eventDictN2D db_setValue:onEventDict forKey:eid];
        }
    }
}


////添加展示需要处理的事件节点
//-(void)handleOnVisible:(NSDictionary *)onVisibleDict
//{
//    __weak typeof(self) weakSelf = self;
//    [self setViewVisible:^{
//        [DBParser circulationActionDict:onVisibleDict andPathId:weakSelf.pathTid];
//    }];
//}
//
////处理消失逻辑
//-(void)handleOnInVisible:(NSDictionary *)onInVisibleDict
//{
//    __weak typeof(self) weakSelf = self;
//    
//    [self setViewInVisible:^{
//        [DBParser circulationActionDict:onInVisibleDict andPathId:weakSelf.pathTid];
//    }];
//}

//ChangeOn监控
-(void)handleChangeOn:(NSString *)changeOnstr
{
    if (!changeOnstr || ![self.metaDict objectForKey:changeOnstr]) {
        return;
    }
    [self.metaDict addObserver:self forKeyPath:changeOnstr options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

//dismissOn监控
- (void)handleDismissOn:(NSString *)dismissOnStr
{
    if (!dismissOnStr || ![self.metaDict objectForKey:dismissOnStr]) {
        return;
    }
    [self.metaDict addObserver:self forKeyPath:dismissOnStr options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)handleDBCallBack:(NSDictionary *)callBackData data:(id)data{
    NSString *key = [callBackData objectForKey:@"msgTo"];
    
    //    //修改指定位置数据
    //    NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    //    NSError *err;
    //    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
    //                                                        options:NSJSONReadingMutableContainers
    //                                                          error:&err];
    if([data isKindOfClass:[NSDictionary class]]){
        NSDictionary *dict = (NSDictionary *)data;
        [[DBPool shareDBPool] setObject:@{key:dict} ToDBMetaPoolWithPathId:self.pathTid];
    } else if([data isKindOfClass:[NSString class]]) {
        NSString *dataStr = (NSString *)data;
        [[DBPool shareDBPool] setObject:@{key:dataStr} ToDBMetaPoolWithPathId:self.pathTid];
    }
    
    [self callActionWithEventDict:callBackData];
}

- (void)sendEventWithEventID:(NSString *)eid data:(id)data {
    NSDictionary *eventDict = [self.eventDictN2D db_objectForKey:eid];
    if(!eventDict){
        return;
    }
    NSString *key = [eventDict objectForKey:@"msgTo"];
    
    if(key.length > 0){
        if([data isKindOfClass:[NSDictionary class]]){
            NSDictionary *dict = (NSDictionary *)data;
            [[DBPool shareDBPool] setObject:@{key:dict} ToDBMetaPoolWithPathId:self.pathTid];
        } else if([data isKindOfClass:[NSString class]]) {
            NSString *dataStr = (NSString *)data;
            [[DBPool shareDBPool] setObject:@{key:dataStr} ToDBMetaPoolWithPathId:self.pathTid];
        }
    }
    
    [self callActionWithEventDict:eventDict];
}

- (void)callActionWithEventDict:(NSDictionary *)eventDict {
    [DBParser circulationActionDict:eventDict andPathId:self.pathTid];
}

//

//数组遍历actionAlias节点
- (void)circulationAliasDict:(NSDictionary *)dict {
    if (dict) {
        [[DBPool shareDBPool] setObject:[dict mutableCopy] ToDBAliasPoolWithPathId:self.pathTid];
    }
}

//刷新treeView
-(void)reloadTreeView
{
    for (int i = 0; i < self.allRenderViewArray.count ; i ++) {
        if (i != 0) {
            DBBaseView *view = self.allRenderViewArray[i];
            //            DBViewModel *model = self.allRenderModelArray[i];
            //            if (model && [view respondsToSelector:@selector(setDataWithModel:andPathId:)]) {
            //                [(UIView<DBViewProtocol> *)view setDataWithModel:model andPathId:self.pathTid];
            //            }
            [view reload];
        }
    }
}

//注册事件
- (void)registerEventWithEventID:(NSString *)eventID andBlock:(DBTreeEventBlock)block
{
    [self.eventDictD2N db_setValue:block forKey:eventID];
}

- (DBTreeEventBlock)eventBlockWithEventId:(NSString *)eventID {
    return [self.eventDictD2N db_objectForKey:eventID];
}

-(void)trace_parser_template:(NSDictionary *)dict andLength:(NSString *)length andDuration:(NSString *)duration
{
    if (!self.tid ||  ![dict objectForKey:@"dbl"] || ![[dict objectForKey:@"dbl"] objectForKey:@"render"] || ![DBValidJudge isValidString:length]) {
        return;
    }
    NSArray *renderArray = [[dict objectForKey:@"dbl"] objectForKey:@"render"];
    NSMutableDictionary *typeNumberDict = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in renderArray) {
        if ([typeNumberDict objectForKey:[dict objectForKey:@"type"]]) {
            NSNumber *number = [typeNumberDict objectForKey:[dict objectForKey:@"type"]];
            number = [NSNumber numberWithInt:(number.intValue + 1)] ;
            [typeNumberDict setObject:number forKey:[dict objectForKey:@"type"]];
        }else{
            [typeNumberDict setObject:[NSNumber numberWithInt:1] forKey:[dict objectForKey:@"type"]];
        }
    }
    
    NSArray *arr = [typeNumberDict allKeys];
    NSString *nodes = @"";
    for (NSString *key in arr) {
        NSString *value = [NSString stringWithFormat:@"%@",[typeNumberDict objectForKey:key]];
        nodes = [nodes stringByAppendingFormat:@"%@:%@,",key,value];
    }
    NSString *node_count = [NSString stringWithFormat:@"%lu",(unsigned long)renderArray.count];
    NSString *file_size = length;
    NSString *accessKey = [[DBPool shareDBPool] getAccessKeyWithPathId:self.pathTid];
    [[DBWrapperManager sharedManager] reportTid:self.tid Key:@"tech_trace_parser_template" accessKey:accessKey params:@{@"node_count":node_count,@"file_size":file_size,@"duration":duration,@"nodes":nodes} frequency:DBReportFrequencyONCE];
    //数据统计 trace_parser_template结束
}

- (NSMutableDictionary *)eventDictD2N {
    if(!_eventDictD2N){
        _eventDictD2N = [[NSMutableDictionary alloc] init];
    }
    return _eventDictD2N;
}
#pragma mark -
- (void)p_debugView {
    self.debugIcon = [[DBDeugSignView alloc] init];
    self.debugIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:self.debugIcon aboveSubview:self.backGroudView];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.debugIcon attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.debugIcon attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.debugIcon attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:53];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.debugIcon attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
    rightConstraint.active = YES;
    topConstraint.active = YES;
    widthConstraint.active = YES;
    heightConstraint.active = YES;
    
#ifdef DEBUG
    [self.debugIcon showIcon];
#endif
}


- (NSMutableDictionary *)eventDictN2D {
    if(!_eventDictN2D){
        _eventDictN2D = [[NSMutableDictionary alloc] init];
    }
    return _eventDictN2D;
}

#pragma mark - DEBUG
- (void)hiddenDebugView {
    self.debugIcon.hidden = YES;
}

//view销毁时调用
- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow == nil) {
        // Will be removed from window, similar to -viewDidUnload.
        // Unsubscribe from any notifications here.
        [[DBPool shareDBPool] removeObjectFromMetaPoolWithPathId:self.pathId];
    }
}
@end
