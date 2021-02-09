//
//  DBXFactory.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/20.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXFactory : NSObject

+ (DBXFactory*)sharedInstance;

- (Class)getModelClassByType:(NSString *)type;

- (Class)getViewClassByType:(NSString *)type;

- (Class)getActionClassByType:(NSString *)type;

- (void)registModelClass:(Class)cls byType:(NSString *)type;
- (void)registViewClass:(Class)cls byType:(NSString *)type;
- (void)registActionClass:(Class)cls byType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
