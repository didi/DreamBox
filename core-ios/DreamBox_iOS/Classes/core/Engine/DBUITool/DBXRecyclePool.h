//
//  DBRecyclePool.h
//  DreamBox_iOS
//
//  Created by didi on 2020/5/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXRecyclePool : NSObject

-(void)setItem:(id)item withIdentifier:(NSString *)identifier;

-(id)getItemWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
