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
#import "DBYogaModel.h"
#import "DBContainerViewReference.h"
#import "DBContainerViewYoga.h"

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
@property (nonatomic, strong) DBContainerView *bgView;

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

- (NSString *)pathIdWithTid:(NSString *)tid accessKey:(NSString *)accessKey {
    return [accessKey stringByAppendingString:tid];
}

#pragma mark - 构建方法
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
    
    NSInteger dbVersion = 3;
    if(dbVersion >= 4){
        if([treeModel isKindOfClass:[DBTreeModelYoga class]]){
            DBTreeModelYoga *yogaModel = (DBTreeModelYoga *)treeModel;
            self.bgView = [DBContainerViewYoga containerViewWithModel:yogaModel pathid:self.pathTid];
            [self addSubview:self.bgView];
            [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(self);
            }];
        }
    } else {
        DBTreeModelReference *referenceModel = (DBTreeModelReference *)treeModel;
        self.bgView = [DBContainerViewReference containerViewWithModel:referenceModel pathid:self.pathTid];
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.width.height.equalTo(self);
        }];
    }
    
}

#pragma mark - reload方法
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

//刷新treeView，几乎可以废弃
-(void)reloadTreeView
{
    for (int i = 0; i < self.allRenderViewArray.count ; i ++) {
        if (i != 0) {
            DBBaseView *view = self.allRenderViewArray[i];
            [view reload];
        }
    }
}

#pragma mark - privateMethods 构建时调用
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

-(void)setCurrentData:(NSDictionary *)metaDict
{
    if (!metaDict || ![metaDict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.metaDict = [metaDict mutableCopy];
}

#pragma mark - 事件相关
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

//数组遍历actionAlias节点
- (void)circulationAliasDict:(NSDictionary *)dict {
    if (dict) {
        [[DBPool shareDBPool] setObject:[dict mutableCopy] ToDBAliasPoolWithPathId:self.pathTid];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"keyPath=%@,object=%@,change=%@,context=%@",keyPath,object,change,context);
    //有数据变化,刷新
    //    [self reloadTreeView];
}

#pragma mark - bridge
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

- (void)callActionWithEventDict:(NSDictionary *)eventDict {
    [DBParser circulationActionDict:eventDict andPathId:self.pathTid];
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

//添加bridge事件监听
-(void)regiterOnEvent:(NSDictionary *)onEventDict {
    if(onEventDict){
        NSString *eid = [onEventDict db_objectForKey:@"eid"];
        if(eid.length > 0){
            [self.eventDictN2D db_setValue:onEventDict forKey:eid];
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

#pragma mark - analyse
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

#pragma mark - getter/setter
-(NSMutableDictionary *)changeOnDict
{
    if (_changeOnDict == nil) {
        _changeOnDict = [NSMutableDictionary dictionary];
    }
    return _changeOnDict;
}

- (NSMutableDictionary *)aliasDict {
    if (!_aliasDict) {
        _aliasDict = [[NSMutableDictionary alloc] init];
    }
    return _aliasDict;
}

- (NSMutableDictionary *)eventDictD2N {
    if(!_eventDictD2N){
        _eventDictD2N = [[NSMutableDictionary alloc] init];
    }
    return _eventDictD2N;
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

#pragma mark -
- (void)p_debugView {
    self.debugIcon = [[DBDeugSignView alloc] init];
    self.debugIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:self.debugIcon aboveSubview:self.bgView];
    
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

#pragma mark - 老的相对布局兼容安卓方法，4.0之后废弃
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


@end
