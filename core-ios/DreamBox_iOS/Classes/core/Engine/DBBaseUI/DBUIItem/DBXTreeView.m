//
//  DBView.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXTreeView.h"
#import "DBXView.h"

#import "DBXProgress.h"
#import "DBXImage.h"
#import "DBXParser.h"
#import "DBXViewModel.h"
#import "DBXService.h"
#import "UIColor+DBXColor.h"
#import "UIView+DBXStrike.h"
#import "DBXHelper.h"
#import "DBXPreProcess.h"
#import "DBXParser.h"
#import "DBXViewProtocol.h"
#import "DBXRecyclePool.h"
#import "DBXService.h"
#import "DBXWrapperManager.h"
#import "DBXFactory.h"
#import "NSDictionary+DBXExtends.h"
#import "DBXDeugSignView.h"
#import <Masonry/Masonry.h>
#import "DBXCallBack.h"
#import "NSArray+DBXExtends.h"
#import <YogaKit/UIView+Yoga.h>
#import "DBXFlexBoxLayout.h"
#import "DBXDefines.h"
#import "DBXYogaModel.h"
#import "DBXContainerViewYoga.h"
#import "DBXContainerViewFrame.h"
#import "DBXRenderModel.h"
#import "DBXRenderFactory.h"
#import "DBXFlexBoxLayout.h"
#import "DBXlistView.h"


static NSString *const kDBMetaExtKey = @"ext";
static NSString *const kDBMetaPoolKey = @"pool";


typedef void(^DBAliasBlock)(NSDictionary *src);

@interface DBXTreeView () <DBContainerViewDelegate>

@property (nonatomic ,copy, readwrite) NSString *accessKey;
@property (nonatomic, strong) NSDictionary*extData;
@property (nonatomic, copy) NSString *tid; //模版id

@property (nonatomic, strong) DBXTreeModel *treeModel;
@property (nonatomic, strong) NSMutableArray *allRenderViewArray;
@property (nonatomic, strong) NSMutableArray *allRenderModelArray;
@property (nonatomic, strong) NSMutableDictionary *aliasDict;
@property (nonatomic, strong) NSMutableDictionary *metaDict;
@property (nonatomic, strong) DBXContainerView *bgView;

@property (nonatomic, strong) DBXRecyclePool *recyclePool;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, strong) NSMutableDictionary *changeOnDict;
@property (nonatomic, strong) NSMutableDictionary *eventDictD2N;
@property (nonatomic, strong) NSMutableDictionary *eventDictN2D;

@property (nonatomic, strong) DBXDeugSignView *debugIcon;
@end

@implementation DBXTreeView
#pragma mark - Public
- (void)dealloc{
    //释放掉所有资源
//    [[DBXPool shareDBPool] removeAccessKeyAndTidDict:self.accessKey andTid:self.tid];
//    [[DBXPool shareDBPool] removeAccessKeyWithPathId:self.pathTid];
//    [[DBXPool shareDBPool] removeTidWithPathId:self.pathTid];
//    [[DBXPool shareDBPool] removeObjectFromMetaPoolWithPathId:self.pathTid];
//    [[DBXPool shareDBPool] removeObjectFromDBExtPoolWithPathId:self.pathTid];
//    [[DBXPool shareDBPool] removeOnEventDictWithPathId:self.pathTid];
//    [[DBXPool shareDBPool] removeObjectFromAliasPoolWithPathId:self.pathTid];
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
    
    [[DBXWrapperManager sharedManager] getDataByTemplateId:tid accessKey:accessKey completionBlock:^(NSError * _Nullable error, NSString * _Nullable data) {
        NSTimeInterval tGetTem = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);//毫秒，精确到个位
        if (!error) {
            DBXProcesssModel *process = [DBXPreProcess preProcess:data];
            //判断是否有map
            if ([process.data db_objectForKey:@"map"]) {
                process.data = [DBXParser parseOriginDict:[process.data  db_objectForKey:@"dbl"] withMap:[process.data db_objectForKey:@"map"]];
            }
            if (process && process.data) {
                NSDictionary *dict = process.data;
                DBXTreeModel *treeModel = [DBXParser parserDict:dict];
                if (treeModel) {
                    NSString *pathId = [self pathIdWithTid:self.tid ? self.tid : [[DBXPool shareDBPool] getAutoIncrementTid] accessKey:self.accessKey];
                    [self p_buildWithTreeModel:treeModel extMeta:ext pathId:pathId];
                    
                    NSTimeInterval tEnd = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);//毫秒，精确到个位
                    NSDictionary *para = @{@"duration":@(tEnd-tStart).stringValue,
                                           @"get_temp_time":@(tGetTem - tStart).stringValue};
                    
                    [[DBXWrapperManager sharedManager] reportTid:tid Key:@"tech_duration_render_total" accessKey:accessKey params:para frequency:DBReportFrequencySAMPLE];
                    [self trace_parser_template:dict andLength:@(data.length).stringValue andDuration:@(tEnd-tStart).stringValue];
                    
                    if (completionBlock) {
                        [[DBXWrapperManager sharedManager] reportTid:tid Key:@"tech_duration_render_result" accessKey:accessKey params:@{@"success":@(1).stringValue} frequency:DBReportFrequencyEVERY];
                        completionBlock(YES,nil);
                    }
                }
            } else {
                if (completionBlock) {
                    
                    NSError *error = [NSError errorWithDomain:@"DB" code:102 userInfo:@{NSLocalizedDescriptionKey:@"模板解密失败"}];
                    [[DBXWrapperManager sharedManager] reportTid:tid Key:@"tech_duration_render_result" accessKey:accessKey params:@{@"success":@"0",@"reason":@"模板解密失败",} frequency:DBReportFrequencyEVERY];
                    completionBlock(NO,error);
                }
            }
        } else {
            if (completionBlock) {
                [[DBXWrapperManager sharedManager] reportTid:tid Key:@"tech_duration_render_result" accessKey:accessKey params:@{@"success":@"0",@"reason":error.localizedDescription} frequency:DBReportFrequencyEVERY];
                completionBlock(NO,error);
            }
        }
    }];
    
}

- (DBXTreeView *)initWithData:(NSString *)data extMeta:(NSDictionary *)ext accessKey:(nonnull NSString *)accessKey tid:(NSString *)tid{
    self.accessKey = accessKey;
    self.tid = tid;
    self = [super init];
    if (self) {
        // 预处理
        DBXProcesssModel *process = [DBXPreProcess preProcess:data];
        if (process && process.data) {
            NSDictionary *dict = process.data;
            DBXTreeModel *treeModel = [DBXParser parserDict:dict];
            if (treeModel) {
                NSString *pathId = [self pathIdWithTid:self.tid ? self.tid : [[DBXPool shareDBPool] getAutoIncrementTid] accessKey:self.accessKey];
                [self p_buildWithTreeModel:treeModel extMeta:ext pathId:pathId];
            }
        }
    }
    return self;
}

- (DBXTreeView *)initWithJsonSting:(NSString *)jsonString extMeta:(NSDictionary *)ext accessKey:(NSString *)accessKey tid:(NSString *)tid{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (!dict) {
        NSLog(@"解析jsonsting失败");
        return nil;
    }
    
    if ([dict objectForKey:@"map"]) {
        dict = [DBXParser parseOriginDict:[dict objectForKey:@"dbl"] withMap:[dict objectForKey:@"map"]];
    }
    
    return [self initWithDict:[dict mutableCopy] extMeta:ext accessKey:accessKey tid:tid];
}


- (DBXTreeView *)initWithDict:(NSDictionary *)treeDict extMeta:(NSDictionary *)ext accessKey:(NSString *)accessKey tid:(NSString *)tid{
    DBXTreeModel *treeModel = [DBXParser parserDict:treeDict];
    return [self initWithModel:treeModel extMeta:ext accessKey:accessKey tid:tid];
}

- (DBXTreeView *)initWithModel:(DBXTreeModel *)treeModel extMeta:(nonnull NSDictionary *)ext accessKey:(nonnull NSString *)accessKey tid:(NSString *)tid
{
    self.accessKey = accessKey;
    self.tid = tid;
    self = [super init];
    if (self) {
        NSString *pathId = [self pathIdWithTid:self.tid ? self.tid : [[DBXPool shareDBPool] getAutoIncrementTid] accessKey:self.accessKey];
        [self p_buildWithTreeModel:treeModel extMeta:ext pathId:pathId];
    }
    return self;
}

- (void)p_buildWithTreeModel:(DBXTreeModel *)treeModel extMeta:(NSDictionary *)ext pathId:(NSString *)pathId{
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
    if (self.accessKey != nil) {
        [[DBXPool shareDBPool] setAllAccessKeyAndTidDict:self.accessKey andTid:self.tid];
    }
    //添加pathId与accessKey对应关系
    [[DBXPool shareDBPool] setAccessKey:self.accessKey ToSearchAccessPoolWithPathId:self.pathTid];
    //添加pathId与tid对应关系
    [[DBXPool shareDBPool] setTid:self.tid ToSearchTidPoolWithPathId:self.pathTid];
    //pathTid与当前treeView的对应关系
    [[DBXPool shareDBPool] setObject:self toViewMapTableWithPathId:self.pathTid];
    //添加到dbpool的meta池
    [[DBXPool shareDBPool] setObject:treeModel.meta ToDBMetaPoolWithPathId:self.pathTid];
    //添加到dbpool的ext池
    [[DBXPool shareDBPool] setObject:ext ToDBExtPoolWithPathId:self.pathTid];
    
    [self regiterOnEvent:treeModel.onEvent];
    [self handleChangeOn:treeModel.changeOn];
    [self circulationAliasDict:treeModel.actionAlias];
    
    DBXTreeModelYoga *yogaModel = (DBXTreeModelYoga *)treeModel;
    //绑定回调事件
    self.callBacks = [yogaModel.render.callbacks mutableCopy];
    [DBXCallBack bindView:self withCallBacks:self.callBacks pathId:self.pathTid];
    
    
    if([yogaModel.render.yogaModel.width isEqualToString:@"fill"]){
        yogaModel.render.yogaModel.width = [NSString stringWithFormat:@"%f", self.frame.size.width];
    }
    
    self.bgView = [DBXRenderFactory renderViewWithTreeModel:yogaModel pathid:self.pathTid];
    self.bgView.userInteractionEnabled = YES;
    [self addSubview:self.bgView];
    self.frame = self.bgView.bounds;
}

- (DBXContainerView *)containerViewWithRenderModel:(DBXRenderModel *)renderModel pathid:(NSString *)pathId {
    DBXContainerView *subContainer = nil;
    if([renderModel.type isEqual:@"yoga"]){
        subContainer = [DBXContainerViewYoga containerViewWithRenderModel:renderModel pathid:pathId delegate:self];
    } else if ([renderModel.type isEqual:@"frame"]){
        subContainer = [DBXContainerViewFrame containerViewWithRenderModel:renderModel pathid:pathId delegate:self];
    }
    return subContainer; 
}

#pragma mark - reload方法
// reload方法，for catalog
- (void)reloadWithData:(NSString *)data extMeta:(NSDictionary *)ext {
    // 预处理
    DBXProcesssModel *process = [DBXPreProcess preProcess:data];
    if (process && process.data) {
        NSDictionary *dict = process.data;
        DBXTreeModel *treeModel = [DBXParser parserDict:dict];
        if (treeModel) {
            [self.bgView removeFromSuperview];
            [self.allRenderViewArray removeAllObjects];
            [self.allRenderModelArray removeAllObjects];
            NSString *pathId = [self pathIdWithTid:self.tid ? self.tid : [[DBXPool shareDBPool] getAutoIncrementTid] accessKey:self.accessKey];
            [self p_buildWithTreeModel:treeModel extMeta:ext pathId:pathId];
        }
    }
}


-(void)reloadTreeView
{
}

#pragma mark - privateMethods 构建时调用
- (void)bindExtensionMetaData:(NSDictionary *)ext {
    self.bgView.pathTid = self.pathTid;
    [DBXCallBack bindView:self withCallBacks:self.callBacks pathId:self.pathTid];
    [self.bgView reloadWithExtDict:ext];
}


- (void)updatePoolMetaData:(NSDictionary *)entries {
    
    if (![DBXValidJudge isValidDictionary:entries]) {
        return;
    }
    if (![DBXValidJudge isValidDictionary:self.metaDict]) {
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
    [[DBXPool shareDBPool] setObject:entries ToDBMetaPoolWithPathId:self.pathTid];
}
- (void)updatePoolMetaKey:(NSString *)key value:(NSString *)value {
    if (![DBXValidJudge isValidString:key] || ![DBXValidJudge isValidString:value]) {
        return;
    }
    
    NSMutableDictionary *entries = [NSMutableDictionary dictionary];
    [entries db_setValue:value forKey:key];
    [self updatePoolMetaData:entries];
    
}

- (void)p_bindExtensionMetaData:(NSDictionary *)ext {
    
    if (![DBXValidJudge isValidDictionary:ext]) {
        return;
    }
    if (![DBXValidJudge isValidDictionary:self.metaDict]) {
        self.metaDict = [NSMutableDictionary dictionary];
    }
    [self.metaDict db_setValue:ext forKey:kDBMetaExtKey];
    
    //添加到dbpool的ext池
    [[DBXPool shareDBPool] setObject:ext ToDBExtPoolWithPathId:self.pathTid];
}

- (BOOL)p_isValidMetaPoolData {
    
    if (![DBXValidJudge isValidDictionary:self.metaDict]) {
        self.metaDict = [NSMutableDictionary dictionary];
    }
    NSDictionary *poolData = [self.metaDict objectForKey:kDBMetaPoolKey];
    return [DBXValidJudge isValidDictionary:poolData];
}

-(void)setCurrentData:(NSDictionary *)metaDict
{
    if (!metaDict || ![metaDict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.metaDict = [metaDict mutableCopy];
}

//ChangeOn监控
-(void)handleChangeOn:(NSString *)changeOnstr
{
    if (!changeOnstr || ![self.metaDict objectForKey:changeOnstr]) {
        return;
    }
    [self.metaDict addObserver:self forKeyPath:changeOnstr options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

//数组遍历actionAlias节点
- (void)circulationAliasDict:(NSDictionary *)dict {
    if (dict) {
        [[DBXPool shareDBPool] setObject:[dict mutableCopy] ToDBAliasPoolWithPathId:self.pathTid];
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
        [[DBXPool shareDBPool] setObject:@{key:dict} ToDBMetaPoolWithPathId:self.pathTid];
    } else if([data isKindOfClass:[NSString class]]) {
        NSString *dataStr = (NSString *)data;
        [[DBXPool shareDBPool] setObject:@{key:dataStr} ToDBMetaPoolWithPathId:self.pathTid];
    }
    
    [self callActionWithEventDict:callBackData];
}

- (void)callActionWithEventDict:(NSDictionary *)eventDict {
    [DBXParser circulationActionDict:eventDict andPathId:self.pathTid];
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
            [[DBXPool shareDBPool] setObject:@{key:dict} ToDBMetaPoolWithPathId:self.pathTid];
        } else if([data isKindOfClass:[NSString class]]) {
            NSString *dataStr = (NSString *)data;
            [[DBXPool shareDBPool] setObject:@{key:dataStr} ToDBMetaPoolWithPathId:self.pathTid];
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
    if (!self.tid ||  ![dict objectForKey:@"dbl"] || ![[dict objectForKey:@"dbl"] objectForKey:@"render"] || ![DBXValidJudge isValidString:length]) {
        return;
    }
    NSArray *renderArray = [[dict objectForKey:@"dbl"] objectForKey:@"render"];
    NSMutableDictionary *typeNumberDict = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in renderArray) {
        if ([typeNumberDict objectForKey:[dict objectForKey:@"_type"]]) {
            NSNumber *number = [typeNumberDict objectForKey:[dict objectForKey:@"_type"]];
            number = [NSNumber numberWithInt:(number.intValue + 1)] ;
            [typeNumberDict setObject:number forKey:[dict objectForKey:@"_type"]];
        }else{
            [typeNumberDict setObject:[NSNumber numberWithInt:1] forKey:[dict objectForKey:@"_type"]];
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
    NSString *accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:self.pathTid];
    [[DBXWrapperManager sharedManager] reportTid:self.tid Key:@"tech_trace_parser_template" accessKey:accessKey params:@{@"node_count":node_count,@"file_size":file_size,@"duration":duration,@"nodes":nodes} frequency:DBReportFrequencyONCE];
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

#pragma mark -
- (void)p_debugView {
//    self.debugIcon = [[DBDeugSignView alloc] init];
//    self.debugIcon.translatesAutoresizingMaskIntoConstraints = NO;
//    [self insertSubview:self.debugIcon aboveSubview:self.bgView];
//    
//    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.debugIcon attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
//    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.debugIcon attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
//    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.debugIcon attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:53];
//    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.debugIcon attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
//    rightConstraint.active = YES;
//    topConstraint.active = YES;
//    widthConstraint.active = YES;
//    heightConstraint.active = YES;
//    
//#ifdef DEBUG
//    [self.debugIcon showIcon];
//#endif
}

#pragma mark - 老的相对布局兼容安卓方法，4.0之后废弃
+ (DBXTreeView *)treeViewWithRender:(NSArray *)renderArray meta:(NSDictionary *)metaDict accessKey:(NSString *)accessKey tid:(NSString *)tid;
{
    //    NSDictionary *ext = [[DBXPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId];
    NSMutableDictionary *treeDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *dblDict = [NSMutableDictionary dictionary];
    dblDict[@"render"] = renderArray;
    if (metaDict) {
        dblDict[@"meta"] = metaDict;
    }
    treeDict[@"dbl"] = dblDict;
    DBXTreeView *treeView = [[DBXTreeView alloc] initWithDict:treeDict extMeta:nil accessKey:accessKey tid:tid];
    [treeView setNeedsLayout];
    [treeView layoutIfNeeded];
    return treeView;
}

+ (DBXTreeView *)treeViewWithRender:(NSArray *)renderArray accessKey:(NSString *)accessKey tid:(NSString *)tid
{
    //    NSDictionary *ext = [[DBXPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId];
    NSMutableDictionary *treeDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *dblDict = [NSMutableDictionary dictionary];
    dblDict[@"render"] = renderArray;
    treeDict[@"dbl"] = dblDict;
    DBXTreeView *treeView = [[DBXTreeView alloc] initWithDict:treeDict extMeta:nil accessKey:accessKey tid:tid];
    [treeView setNeedsLayout];
    [treeView layoutIfNeeded];
    return treeView;
}

- (void)searchDBXDelegateEndableInstance:(UIView *)view receiver:(id)receiver {
    if ([view isKindOfClass:[DBXlistView class]]) {
        if ([view respondsToSelector:@selector(setDelegate:)]) {
            [view performSelector:@selector(setDelegate:) withObject:receiver];
        }
    }
    for (UIView *subView in view.subviews) {
        [self searchDBXDelegateEndableInstance:subView receiver:receiver];
    }
}

@end
