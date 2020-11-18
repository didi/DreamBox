//
//  NSString+DBExtends.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/14.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Base64)
/**
*  转换为Base64编码
*/
- (NSString *)db_base64EncodedString;
/**
*  将Base64编码还原
*/
- (NSString *)db_base64DecodedString;


/// 32位小写
- (NSString *)db_MD5ForLower32Bate;
/// 32位大写
- (NSString *)db_MD5ForUpper32Bate;


- (NSDictionary*)db_toJSONDictionary;

#pragma mark -
- (NSString *)db_urlEncode;
- (NSString *)db_urlDecode;

@end

NS_ASSUME_NONNULL_END
