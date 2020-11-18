//
//  DBRecyclePool.m
//  DreamBox_iOS
//
//  Created by didi on 2020/5/29.
//

#import "DBRecyclePool.h"



@interface DBRecyclePool()

@property (nonatomic ,strong) NSMutableDictionary *dataPool;

@end

@implementation DBRecyclePool


-(void)setItem:(id)item withIdentifier:(NSString *)identifier
{
    if (item && identifier) {
        self.dataPool[identifier] = item;
    }
}

-(id)getItemWithIdentifier:(NSString *)identifier
{   id item = nil;
    if (identifier) {
       item = [self.dataPool objectForKey:identifier];
    }
    return item;
}

-(NSMutableDictionary *)dataPool
{
    if (!_dataPool) {
        _dataPool = [NSMutableDictionary dictionary];
    }
    return _dataPool;
}


@end
