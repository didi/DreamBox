//
//  DBXFactory.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/20.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXFactory.h"

@interface DBXFactory ()

@property (nonatomic, strong) NSMutableDictionary *allViewClassTypesArray;
@property (nonatomic, strong) NSMutableDictionary *allModelClassTypesArray;
@property (nonatomic, strong) NSMutableDictionary *allActionClassTypesArray;

@end

@implementation DBXFactory

+ (DBXFactory*)sharedInstance
{
    static DBXFactory *factory= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory = [[DBXFactory alloc] init];
    });
    return factory;
}

- (instancetype)init
{
    if (self = [super init]) {
        //view种类数组
        self.allModelClassTypesArray = [NSMutableDictionary dictionary];
        
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBXViewModel") forKey:@"pack"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBXViewModel") forKey:@"view"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBXImageModel") forKey:@"image"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBXTextModel") forKey:@"text"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBXRenderModel") forKey:@"layout"];
        
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBXProgressModel") forKey:@"progress"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBXlistModelV2") forKey:@"list"];
  
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBXFlowModel") forKey:@"flow"];
        [self.allModelClassTypesArray setValue:NSClassFromString(@"DBXLoadingModel") forKey:@"loading"];
        
        //model种类数组
        self.allViewClassTypesArray = [NSMutableDictionary dictionary];
        
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBXView") forKey:@"group"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBXView") forKey:@"pack"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBXView") forKey:@"view"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBXImage") forKey:@"image"];
        
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBXTextV2") forKey:@"text"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBXlistView") forKey:@"list"];
        
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBXProgress") forKey:@"progress"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBXFlowView") forKey:@"flow"];
        [self.allViewClassTypesArray setValue:NSClassFromString(@"DBXLoading") forKey:@"loading"];
        //action种类
        self.allActionClassTypesArray = [NSMutableDictionary dictionary];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXLogAction") forKey:@"log"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXNetAction") forKey:@"net"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXTraceAction") forKey:@"trace"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXNavAction") forKey:@"nav"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXStorageAction") forKey:@"storage"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXDialogAction") forKey:@"dialog"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXToastAction") forKey:@"toast"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXChangeMetaAction") forKey:@"changeMeta"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXInvokeAction") forKey:@"invoke"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXClosePageAction") forKey:@"closePage"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXSendEventAction") forKey:@"sendEvent"];
        [self.allActionClassTypesArray setValue:NSClassFromString(@"DBXOnEventAction") forKey:@"onEvent"];
        
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
