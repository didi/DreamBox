//
//  DBWssTest.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/6/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol DBWSSDelegate <NSObject>

- (void)refreshViewWithData:(NSString *)data;

- (void)socketBindFailed;

@end

@interface DBWssTest : NSObject

@property (nonatomic, weak) id<DBWSSDelegate> delegate;

+ (instancetype)shareInstance;

- (void)openWSSConnectWithIPStr:(NSString *)ipStr;

@end

NS_ASSUME_NONNULL_END
