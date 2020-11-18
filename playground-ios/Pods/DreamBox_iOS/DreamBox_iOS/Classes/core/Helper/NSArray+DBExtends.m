//
//  NSArray+DBExtends.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/8/7.
//

#import "NSArray+DBExtends.h"
#import "NSDictionary+DBExtends.h"

@implementation NSArray (DBExtends)

- (id)db_ObjectAtIndex:(NSUInteger)index{
    if (index <self.count) {
        return self[index];
    }else{
        return nil;
    }
}

- (NSMutableArray *)mutableArrayDeeoCopy{
    NSMutableArray * array = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id objOject;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            objOject = [obj mutableDicDeepCopy];
        }else if ([obj isKindOfClass:[NSArray class]]){
            objOject = [obj mutableArrayDeeoCopy];
        }else{
            objOject = obj;
        }
        [array addObject:objOject];
    }];
    
    return array;
}

@end
