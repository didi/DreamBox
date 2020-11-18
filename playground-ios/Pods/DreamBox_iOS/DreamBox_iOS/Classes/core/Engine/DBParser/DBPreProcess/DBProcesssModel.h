//
//  DBProcesssModel.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/14.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBProcesssModel : NSObject

@property (nonatomic, copy) NSString *md5_info;
@property (nonatomic, copy) NSString *cli_ver_info;
@property (nonatomic, copy) NSString *sdk_ver_info;
@property (nonatomic, copy) NSString *empty_info;//暂留区

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSString *jsonDataStr;
@end

NS_ASSUME_NONNULL_END
