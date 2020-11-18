//
//  DBActionProtocol.h
//  DreamBox_iOS
//
//  Created by didi on 2020/7/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DBActionProtocol <NSObject>

@required

-(void)actWithDict:(NSDictionary *)dict andPathId:(NSString *)pathId;

@end

NS_ASSUME_NONNULL_END
