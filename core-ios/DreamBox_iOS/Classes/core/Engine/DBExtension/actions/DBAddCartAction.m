//
//  DBAddCartAction.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2021/1/18.
//

#import "DBAddCartAction.h"
#import "DBPool.h"
#import "NSDictionary+DBExtends.h"
#import "NSArray+DBExtends.h"

@implementation DBAddCartAction

- (void)actWithDict:(NSDictionary*)originDict andPathId:(NSString *)originPathId frame:(CGRect)frame{
    NSString *pathId = nil;
    NSString *indexStr = nil;
    
    NSRange range = [originPathId rangeOfString:@"&"];
    if(range.location > 0 && range.length > 0){
        pathId = [originPathId substringToIndex:range.location];
        indexStr = [originPathId substringFromIndex:(range.location + range.length)];
    }
    
    NSDictionary *itemDict = [[DBPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId];
    NSArray *goods = [itemDict objectForKey:@"goods"];
    NSDictionary *goodItem = [goods db_ObjectAtIndex:indexStr.integerValue];
    NSArray *actionList = [goodItem objectForKey:@"actionList"];
    NSMutableDictionary *actionParams;
    for(NSDictionary *actionItem in actionList){
        NSString *type = [actionItem objectForKey:@"actionType"];
        if([type isEqualToString:@"AddCart"]){
            actionParams = [actionItem mutableCopy];
        }
    }
    [actionParams setValue:NSStringFromCGRect(frame) forKey:@"buttonFrame"];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    [userInfo db_setValue:actionParams forKey:@"actionParams"];
    [userInfo db_setValue:itemDict forKey:@"bizDict"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:pathId object:nil userInfo:userInfo];
    
}

@end
