//
//  NSArray+DBExtends.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/8/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (DBXExtends)


- (id)db_ObjectAtIndex:(NSUInteger)index;

- (NSMutableArray *)mutableArrayDeeoCopy;

@end

@interface NSMutableArray (DBXExtends)

- (void)db_addObject:(id)object;

@end

NS_ASSUME_NONNULL_END
