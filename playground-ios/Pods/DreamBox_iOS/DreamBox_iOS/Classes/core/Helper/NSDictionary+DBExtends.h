//
//  NSDictionary+DBExtends.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/21.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary <KeyType, ObjectType> (DBExtends)

- (id)db_valueForPathId:(NSString *)pathId;

- (BOOL)db_hasKey:(KeyType <NSCopying>)key;

- (NSString*)db_stringForKey:(KeyType <NSCopying>)key;

- (NSString*)db_stringForKey:(KeyType <NSCopying>)key defaultValue:(NSString *)defaultValue;

- (NSNumber*)db_numberForKey:(KeyType <NSCopying>)key;

- (NSDecimalNumber *)db_decimalNumberForKey:(KeyType <NSCopying>)key;

- (NSArray*)db_arrayForKey:(KeyType <NSCopying>)key;

- (NSDictionary*)db_dictionaryForKey:(KeyType <NSCopying>)key;

- (NSInteger)db_integerForKey:(KeyType <NSCopying>)key;

- (NSUInteger)db_unsignedIntegerForKey:(KeyType <NSCopying>)key;

- (BOOL)db_boolForKey:(KeyType <NSCopying>)key;
// 从 NSDictionary 中获取 key 对应的 bool 型value; 若无，则返回 defaultValue
- (BOOL)db_boolForKey:(KeyType <NSCopying>)aKey defaultValue:(BOOL)defaultValue;

- (int16_t)db_int16ForKey:(KeyType <NSCopying>)key;

- (int32_t)db_int32ForKey:(KeyType <NSCopying>)key;

- (int64_t)db_int64ForKey:(KeyType <NSCopying>)key;

- (char)db_charForKey:(KeyType <NSCopying>)key;

- (short)db_shortForKey:(KeyType <NSCopying>)key;

- (float)db_floatForKey:(KeyType <NSCopying>)key;

- (double)db_doubleForKey:(KeyType <NSCopying>)key;

- (long long)db_longLongForKey:(KeyType <NSCopying>)key;

- (unsigned long long)db_unsignedLongLongForKey:(KeyType <NSCopying>)key;

- (NSDate *)db_dateForKey:(KeyType <NSCopying>)key dateFormat:(NSString *)dateFormat;

- (id)db_objectForKey:(KeyType <NSCopying>)key;

- (NSMutableDictionary *)mutableDicDeepCopy;

/// 是否为有效的字典
+ (BOOL)db_isValid:(NSDictionary *)value;

///是否为空字典
+ (BOOL)db_isEmpty:(NSDictionary *)value;

@end


#pragma --mark NSMutableDictionary setter

@interface NSMutableDictionary <KeyType, ObjectType> (DBSafeAccess)

- (void)db_setValue:(ObjectType)aValue forKey:(KeyType <NSCopying>)key;

- (void)db_setValueEx:(ObjectType)aValue forKey:(KeyType <NSCopying>)aKey;

- (void)db_setString:(NSString *)i forKey:(KeyType <NSCopying>)key;

- (void)db_setBool:(BOOL)i forKey:(KeyType <NSCopying>)key;

- (void)db_setInt:(int)i forKey:(KeyType <NSCopying>)key;

- (void)db_setInteger:(NSInteger)i forKey:(KeyType <NSCopying>)key;

- (void)db_setUnsignedInteger:(NSUInteger)i forKey:(KeyType <NSCopying>)key;

- (void)db_setChar:(char)c forKey:(KeyType <NSCopying>)key;

- (void)db_setFloat:(float)i forKey:(KeyType <NSCopying>)key;

- (void)db_setDouble:(double)i forKey:(KeyType <NSCopying>)key;

- (void)db_setLongLong:(long long)i forKey:(KeyType <NSCopying>)key;

/// 是否为有效的可变字典
+ (BOOL)db_isValid:(NSMutableDictionary *)value;

///是否为空b的可变字典
+ (BOOL)db_isEmpty:(NSMutableDictionary *)value;

@end

NS_ASSUME_NONNULL_END
