//
//  DBFactory.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/20.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBFactory.h"

@interface DBFactory ()

@property (nonatomic, strong) NSMutableDictionary *allViewClassTypesArray;
@property (nonatomic, strong) NSMutableDictionary *allModelClassTypesArray;
@property (nonatomic, strong) NSMutableDictionary *allActionClassTypesArray;

@end

@implementation DBFactory

+ (DBFactory*)sharedInstance
{
    static DBFactory *factory= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory = [[DBFactory alloc] init];
    });
    return factory;
}

- (instancetype)init
{
    int dbVersion = 4;
    if (self = [super init]) {
        //view种类数组
        self.allModelClassTypesArray = [NSMutableDictionary dictionary];
        
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBViewModel") forKey:@"pack"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBViewModel") forKey:@"view"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBImageModel") forKey:@"image"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBTextModel") forKey:@"text"];

        
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBProgressModel") forKey:@"progress"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBListModel") forKey:@"list"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBFlowModel") forKey:@"flow"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBLoadingModel") forKey:@"loading"];
        
        //model种类数组
        self.allViewClassTypesArray = [NSMutableDictionary dictionary];
        
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBView") forKey:@"group"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBView") forKey:@"pack"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBView") forKey:@"view"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBImage") forKey:@"image"];
        
        
        if(dbVersion >= 4){
            [self.allViewClassTypesArray setValue:NSClassFromString(@"DBTextV2") forKey:@"text"];
        } else {
            [self.allViewClassTypesArray setValue:NSClassFromString(@"DBText") forKey:@"text"];
        }
        
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBProgress") forKey:@"progress"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBCollectionList") forKey:@"list"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBFlowView") forKey:@"flow"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBLoading") forKey:@"loading"];
        //action种类
        self.allActionClassTypesArray = [NSMutableDictionary dictionary];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBLogAction") forKey:@"log"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBNetAction") forKey:@"net"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBTraceAction") forKey:@"trace"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBNavAction") forKey:@"nav"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBStorageAction") forKey:@"storage"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBDialogAction") forKey:@"dialog"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBToastAction") forKey:@"toast"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBChangeMetaAction") forKey:@"changeMeta"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBInvokeAction") forKey:@"invoke"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBClosePageAction") forKey:@"closePage"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBSendEventAction") forKey:@"sendEvent"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBOnEventAction") forKey:@"onEvent"];
        
    }
    return self;
}

- (void)registModelClass:(Class)cls byType:(NSString *)type
{
    if (!cls || !type) {
        return;
    }
    [self.allModelClassTypesArray setValue:cls forKey:type];
}


- (void)registViewClass:(Class)cls byType:(NSString *)type
{
    if (!cls || !type) {
        return;
    }
    [self.allViewClassTypesArray setValue:cls forKey:type];
}

- (void)registActionClass:(Class)cls byType:(NSString *)type
{
    if (!cls || !type) {
        return;
    }
    [self.allActionClassTypesArray setValue:cls forKey:type];
}


- (Class)getModelClassByType:(NSString *)type
{
    if ([self.allModelClassTypesArray objectForKey:type]) {
        return (Class)[self.allModelClassTypesArray objectForKey:type];
    }
    return nil;
}

- (Class)getViewClassByType:(NSString *)type
{
    if ([self.allViewClassTypesArray objectForKey:type]) {
        return (Class)[self.allViewClassTypesArray objectForKey:type];
    }
     
    return nil;
}

- (Class)getActionClassByType:(NSString *)type
{
    if ([self.allActionClassTypesArray objectForKey:type]) {
        return (Class)[self.allActionClassTypesArray objectForKey:type];
    }
     
    return nil;
}
@end
