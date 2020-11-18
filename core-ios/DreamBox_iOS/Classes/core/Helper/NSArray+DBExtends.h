//
//  NSArray+DBExtends.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/8/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (DBExtends)


- (id)db_ObjectAtIndex:(NSUInteger)index;

- (NSMutableArray *)mutableArrayDeeoCopy;

@end

NS_ASSUME_NONNULL_END
