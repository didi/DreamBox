//
//  NSDictionary+DBExtends.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/21.
//  Copyright © 2020 didi. All rights reserved.
//

#import "NSDictionary+DBExtends.h"
#import "NSArray+DBExtends.h"

@implementation NSDictionary (DBExtends)

- (id)db_valueForPathId:(NSString *)pathId {
    id val;
    @try {
        val = [self valueForKeyPath:pathId];
    } @catch (NSException *exception) {
        return nil;
    } @finally {
        return val;
    }
}

- (BOOL)db_hasKey:(id<NSCopying>)key {
    return [self objectForKey:key] != nil;
}

- (NSString *)db_stringForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString*)value;
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    
    return nil;
}

- (NSString *)db_stringForKey:(id<NSCopying>)key defaultValue:(NSString *)defaultValue {
    if (key != nil && [(NSObject *)key conformsToProtocol:@protocol(NSCopying)]) {
        id ret = [self objectForKey:key];
        if (ret != nil && ret != [NSNull null]) {
            if ([ret isKindOfClass:[NSString class]]) {
                    return ret;
            }
            else if ([ret isKindOfClass:[NSDecimalNumber class]]) {
                return [NSString stringWithFormat:@"%@", ret];
            }
            else if ([ret isKindOfClass:[NSNumber class]]) {
                return [NSString stringWithFormat:@"%@", ret];
            }
        }
    }

    return defaultValue;
}

- (NSNumber *)db_numberForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber*)value;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        return [f numberFromString:(NSString*)value];
    }
    
    return nil;
}

- (NSDecimalNumber *)db_decimalNumberForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber * number = (NSNumber*)value;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString * str = (NSString*)value;
        return [str isEqualToString:@""] ? nil : [NSDecimalNumber decimalNumberWithString:str];
    }
    
    return nil;
}

- (NSArray*)db_arrayForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    
    return nil;
}

- (NSDictionary*)db_dictionaryForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    
    return nil;
}

- (NSInteger)db_integerForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }
    
    return 0;
}

- (NSUInteger)db_unsignedIntegerForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:value];
        return [number unsignedIntegerValue];
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedIntegerValue];
    }
    
    return 0;
}

- (BOOL)db_boolForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    
    return NO;
}

// 从 NSDictionary 中获取 key 对应的 bool 型value; 若无，则返回 defaultValue
- (BOOL)db_boolForKey:(id<NSCopying>)key defaultValue:(BOOL)defaultValue {
    if (key != nil && [(NSObject *)key conformsToProtocol:@protocol(NSCopying)]) {
        id ret = [self objectForKey:key];
        if (ret != nil && ret != [NSNull null] && ([ret isKindOfClass:[NSDecimalNumber class]] || [ret isKindOfClass:[NSNumber class]] || [ret isKindOfClass:[NSString class]])) {
            return [ret boolValue];
        }
    }
    
    return defaultValue;
}

- (int16_t)db_int16ForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value shortValue];
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    
    return 0;
}

- (int32_t)db_int32ForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    
    return 0;
}

- (int64_t)db_int64ForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value longLongValue];
    }
    
    return 0;
}

- (char)db_charForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value charValue];
    }
    
    return 0;
}

- (short)db_shortForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];

    if ([value isKindOfClass:[NSNumber class]]) {
        return [value shortValue];
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    
    return 0;
}

- (float)db_floatForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];

    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    }
    
    return 0;
}

- (double)db_doubleForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];

    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value doubleValue];
    }
    
    return 0;
}

- (long long)db_longLongForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value longLongValue];
    }
    
    return 0;
}

- (unsigned long long)db_unsignedLongLongForKey:(id<NSCopying>)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedLongLongValue];
    }
    return 0;
}

- (NSDate *)db_dateForKey:(id<NSCopying>)key dateFormat:(NSString *)dateFormat {
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = dateFormat;
    id value = [self objectForKey:key];
    
    if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""] &&dateFormat) {
        return [formater dateFromString:value];
    }
    return nil;
}

- (id)db_objectForKey:(id<NSCopying>)key{
    if (!key || ![self objectForKey:key]) {
        return nil;
    }
    return [self objectForKey:key];
}

+ (BOOL)db_isValid:(NSDictionary *)value {
    if (!value || ![value isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    return YES;
}

+ (BOOL)db_isEmpty:(NSDictionary *)value {
    if ([NSDictionary db_isValid:value]) {
        return value.count < 1;
    }
    return YES;
}

- (NSMutableDictionary *)mutableDicDeepCopy{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:[self count]];
    NSArray *keys=[self allKeys];
    for(id key in keys)
    {
        //循环读取复制每一个元素
        id value=[self objectForKey:key];
        id copyValue;
        
        // 如果是字典，递归调用
        if ([value isKindOfClass:[NSDictionary class]]) {
            copyValue=[value mutableDicDeepCopy];
            //如果是数组，数组数组深拷贝
        }else if([value isKindOfClass:[NSArray class]])
            
        {
            copyValue=[value mutableArrayDeeoCopy];
        }else{
            copyValue = value;
        }
        [dict setObject:copyValue forKey:key];
    }
    return dict;
}

@end


@implementation NSMutableDictionary (DBSafeAccess)

- (void)db_setValue:(id)i forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    if (i != nil) {
        [self setObject:i forKey:key];
    }
}

// 在aValue为nil时，删除原来的key
- (void)db_setValueEx:(id)aValue forKey:(id<NSCopying>)aKey {
    if (!aKey) {
        NSParameterAssert(aKey);
        return;
    }
    
    if (aValue != nil) {
        [self setObject:aValue forKey:aKey];
    } else {
        [self removeObjectForKey:aKey];
    }
}

- (void)db_setString:(NSString*)i forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    [self db_setValue:i forKey:key];
}

- (void)db_setBool:(BOOL)i forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    self[key] = @(i);
}

- (void)db_setInt:(int)i forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    self[key] = @(i);
}

- (void)db_setInteger:(NSInteger)i forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    self[key] = @(i);
}

- (void)db_setUnsignedInteger:(NSUInteger)i forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    self[key] = @(i);
}

- (void)db_setChar:(char)c forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    self[key] = @(c);
}

- (void)db_setFloat:(float)i forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    self[key] = @(i);
}

-(void)db_setDouble:(double)i forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    self[key] = @(i);
}

- (void)db_setLongLong:(long long)i forKey:(id<NSCopying>)key {
    if (!key) {
        NSParameterAssert(key);
        return;
    }
    
    self[key] = @(i);
}

+ (BOOL)db_isValid:(NSMutableDictionary *)value {
    if (!value || ![value isMemberOfClass:[NSMutableDictionary class]]) {
        return NO;
    }
    return YES;
}

+ (BOOL)db_isEmpty:(NSMutableDictionary *)value {
    if ([self db_isValid:value]) {
        return value.count < 1;
    }
    return YES;
}

@end
