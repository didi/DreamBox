//
//  DBPool.m
//  DreamBox_iOS
//
//  Created by didi on 2020/6/18.
//

#import "DBXPool.h"
#import "NSDictionary+DBXExtends.h"
#import "NSArray+DBXExtends.h"

@interface DBXPool()

@property(nonatomic ,strong) NSMutableDictionary *dbGBPoolDict;// 全局 accessKey 需要暴露
@property(nonatomic ,strong) NSMutableDictionary *dbExtPoolDict;// tid级别 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *dbMetaPoolDict;// tid级别 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *dbAliasPoolDict;// tid级别 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *searchAccessDict; // 全局 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *searchTidDict; // 全局 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *dbOnEventDict; // tid级别 无需暴露
@property(nonatomic ,strong) NSMapTable *dbViewMapTable; // tid级别 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *dbAllAccessKeyAndTidDict; // tid级别,存放注册过的accessKey&tid列表，给playGround&debugTool使用
@property(nonatomic ,assign) int autoTid; // 默认为0,生成时自增

@end

@implementation DBXPool

+(instancetype)shareDBPool{
    static DBXPool *dbPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbPool =  [[DBXPool alloc] init];
        dbPool.dbAllAccessKeyAndTidDict = [NSMutableDictionary dictionary];
        dbPool.searchAccessDict = [NSMutableDictionary dictionary];
        dbPool.searchTidDict = [NSMutableDictionary dictionary];
        dbPool.dbExtPoolDict = [NSMutableDictionary dictionary];

        
        dbPool.dbGBPoolDict = [NSMutableDictionary dictionary];
        dbPool.dbMetaPoolDict = [NSMutableDictionary dictionary];
        dbPool.dbAliasPoolDict = [NSMutableDictionary dictionary];
        
        
        dbPool.dbViewMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        dbPool.autoTid = 0;
    });
    return dbPool;
}

-(NSRegularExpression *)regex{
    if(!_regex){
        NSError *error = nil;
        _regex = [NSRegularExpression regularExpressionWithPattern:@"(\\$)\\S*?(\\})"  options:NSRegularExpressionCaseInsensitive error:&error];
    }
    return _regex;
}

#pragma mark - accessKey列表，accessKey - tid列表
- (void)setAllAccessKeyAndTidDict:(NSString *)accessKey andTid:(NSString *)tid {
    if (!tid || !accessKey) {
        return;
    }

    if ([[DBXPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] && [[[DBXPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [[[DBXPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] mutableCopy];
        if(![array containsObject:tid]){
            [array db_addObject:tid];
            [[DBXPool shareDBPool].dbAllAccessKeyAndTidDict db_setValue:array forKey:accessKey];
        }
    }else{
        NSMutableArray *array = [NSMutableArray array];
        [array db_addObject:tid];
        [[DBXPool shareDBPool].dbAllAccessKeyAndTidDict db_setValue:array forKey:accessKey];
    }
}

- (NSDictionary *)getAccessKeyAndTidDict {
    return self.dbAllAccessKeyAndTidDict;
}

- (void)removeAccessKeyAndTidDict:(NSString *)accessKey andTid:(NSString *)tid {
    if (!tid || !accessKey) {
        return;
    }
    
    if ([[DBXPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] && [[[DBXPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] isKindOfClass:[NSArray class]]){
        NSMutableArray *array = [[[DBXPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] mutableCopy];
        if(![array containsObject:tid]){
            [array removeObject:tid];
            if(array.count > 0){
                [[DBXPool shareDBPool].dbAllAccessKeyAndTidDict db_setValue:array forKey:accessKey];
            } else {
                [[DBXPool shareDBPool].dbAllAccessKeyAndTidDict removeObjectForKey:accessKey];
            }
        }
    }
}

#pragma mark - accessKey与pathId的对应关系，根据pathId索引accessKey
- (void)setAccessKey:(NSString *)object ToSearchAccessPoolWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }

    if (![[DBXPool shareDBPool] getAccessKeyWithPathId:pathId]) {
        [[DBXPool shareDBPool].searchAccessDict db_setValue:object forKey:pathId];
    }
}

- (NSString *)getAccessKeyWithPathId:(NSString *)pathId {
    NSString *objc = [[DBXPool shareDBPool].searchAccessDict db_objectForKey:pathId];
    return objc;
}

- (void)removeAccessKeyWithPathId:(NSString *)pathId {
    if([[DBXPool shareDBPool].searchAccessDict db_objectForKey:pathId]){
        [[DBXPool shareDBPool].searchAccessDict removeObjectForKey:pathId];
    }
}

#pragma mark - tid与pathId的对应关系，根据pathId索引tid
- (void)setTid:(NSString *)object ToSearchTidPoolWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }
    
    if (![[DBXPool shareDBPool] getTidWithPathId:pathId]) {
        [[DBXPool shareDBPool].searchTidDict db_setValue:object forKey:pathId];
    }
}

- (NSString *)getTidWithPathId:(NSString *)pathId {
    NSString *objc = [[DBXPool shareDBPool].searchTidDict db_objectForKey:pathId];
    return objc;
}

- (void)removeTidWithPathId:(NSString *)pathId {
    if([[DBXPool shareDBPool].searchTidDict db_objectForKey:pathId]){
        [[DBXPool shareDBPool].searchTidDict removeObjectForKey:pathId];
    }
}

#pragma mark - view与pathId的对应关系，根据pathId索引view
-(id)getDBViewWithPathId:(NSString *)pathId {
    id objc = [[DBXPool shareDBPool].dbViewMapTable objectForKey:pathId];
    return objc;
}

-(void)setObject:(id)object toViewMapTableWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }

    [[DBXPool shareDBPool].dbViewMapTable setObject:object forKey:pathId];
}

- (id)getDBViewWithTid:(NSString *)tid andAccessKey:(NSString *)accessKey {
    NSString *pathTid = [accessKey stringByAppendingString:tid];
    id objc = [[DBXPool shareDBPool].dbViewMapTable objectForKey:pathTid];
    return objc;
}


#pragma mark - metaData与pathId的对应关系，根据pathId索引metaData
-(void)setObject:(NSDictionary *)object ToDBMetaPoolWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }
        
    if ([[DBXPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId]) {
        NSMutableDictionary *dict = [[DBXPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId];
        [object enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [dict setValue:obj forKeyPath:key];
        }];
    }else{
        NSMutableDictionary *objectM = [object mutableDicDeepCopy];
        NSMutableDictionary *dictM = [NSMutableDictionary new];
        [objectM enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [dictM setValue:obj forKeyPath:key];
        }];
        [[DBXPool shareDBPool].dbMetaPoolDict setObject:dictM forKey:pathId];
    }
}

- (id)getObjectFromDBMetaPoolWithPathId:(NSString *)pathId {
    id objc = [[DBXPool shareDBPool].dbMetaPoolDict db_objectForKey:pathId];
    return objc;
}

- (void)removeObjectFromMetaPoolWithPathId:(NSString *)pathId{
    if (!pathId) {
        return;
    }

    if ([[DBXPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId]) {
        [[DBXPool shareDBPool].dbMetaPoolDict removeObjectForKey:pathId];
    }
}

#pragma mark - ext与pathId的对应关系，根据pathId索引metaData
- (void)setObject:(NSDictionary *)object ToDBExtPoolWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }
    
    NSMutableDictionary *dict = [[DBXPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId];
    if (dict) {
        [object enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [dict setValue:obj forKeyPath:key];
        }];
    }else{
        NSMutableDictionary *objectM = [object mutableDicDeepCopy];
        NSMutableDictionary *dictM = [NSMutableDictionary new];
        [objectM enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [dictM setValue:obj forKeyPath:key];
        }];
        [[DBXPool shareDBPool].dbExtPoolDict setObject:dictM forKey:pathId];
    }
}


- (id)getObjectFromDBExtPoolWithPathId:(NSString *)pathId {
    id objc = [[DBXPool shareDBPool].dbExtPoolDict db_objectForKey:pathId];
    return objc;
}

- (void)removeObjectFromDBExtPoolWithPathId:(NSString *)pathId {
    if([[DBXPool shareDBPool].dbExtPoolDict db_objectForKey:pathId]){
        [[DBXPool shareDBPool].dbExtPoolDict removeObjectForKey:pathId];
    }
}


#pragma mark - alias与pathId的对应关系，根据pathId索引metaData
-(void)setObject:(NSDictionary *)object ToDBAliasPoolWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }
    
    if ([[DBXPool shareDBPool] getObjectFromAliasPoolWithPathId:pathId]) {
        NSMutableDictionary *dict = [[[DBXPool shareDBPool] getObjectFromAliasPoolWithPathId:pathId] mutableCopy];
        [dict addEntriesFromDictionary:object];
        [[DBXPool shareDBPool].dbAliasPoolDict setObject:dict forKey:pathId];
    }else{
        [[DBXPool shareDBPool].dbAliasPoolDict setObject:object forKey:pathId];
    }
}

- (id)getObjectFromAliasPoolWithPathId:(NSString *)pathId {
    id objc = [[DBXPool shareDBPool].dbAliasPoolDict db_objectForKey:pathId];
    return objc;
}

- (void)removeObjectFromAliasPoolWithPathId:(NSString *)pathId {
    if([[DBXPool shareDBPool].dbAliasPoolDict db_objectForKey:pathId]){
        [[DBXPool shareDBPool].dbAliasPoolDict removeObjectForKey:pathId];
    }
}


#pragma mark - alias与pathId的对应关系，根据pathId索引metaData
- (void)setObject:(NSDictionary *)object ToDBOnEventDictWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }
        
    if ([[DBXPool shareDBPool] getOnEventDictWithPathId:pathId]) {
        NSMutableDictionary *dict = [[[DBXPool shareDBPool] getOnEventDictWithPathId:pathId] mutableCopy];
        [dict addEntriesFromDictionary:object];
        [[DBXPool shareDBPool].dbOnEventDict setObject:dict forKey:pathId];
    }else{
        [[DBXPool shareDBPool].dbOnEventDict setObject:object forKey:pathId];
    }
}


- (NSDictionary *)getOnEventDictWithPathId:(NSString *)pathId {
    NSDictionary *objc = [[DBXPool shareDBPool].dbOnEventDict db_objectForKey:pathId];
    return objc;
}

- (void)removeOnEventDictWithPathId:(NSString *)pathId {
    if([[DBXPool shareDBPool].dbOnEventDict db_objectForKey:pathId]){
        [[DBXPool shareDBPool].dbOnEventDict removeObjectForKey:pathId];
    }
}

#pragma mark - alias与pathId的对应关系，根据pathId索引metaData
-(void)setObject:(NSDictionary *)object ToDBGlobalPoolWithPathId:(NSString *)pathId
{
    if (!pathId || !object) {
        return;
    }
    
    if ([[DBXPool shareDBPool] getObjectFromDBGlobalPoolWithPathId:pathId]) {
        NSMutableDictionary *dict = [[[DBXPool shareDBPool] getObjectFromDBGlobalPoolWithPathId:pathId] mutableCopy];
        [dict addEntriesFromDictionary:object];
        [[DBXPool shareDBPool].dbGBPoolDict setObject:dict forKey:pathId];
    }else{
        [[DBXPool shareDBPool].dbGBPoolDict setObject:object forKey:pathId];
    }
}

-(id)getObjectFromDBGlobalPoolWithPathId:(NSString *)pathId {
    id objc = [[DBXPool shareDBPool].dbGBPoolDict db_objectForKey:pathId];
    return objc;
}

#pragma mark - 自增tid
-(NSString *)getAutoIncrementTid
{
    [DBXPool shareDBPool].autoTid ++;
    NSString *autoTid = [NSString stringWithFormat:@"%d",[DBXPool shareDBPool].autoTid];
    return autoTid;
}
@end
