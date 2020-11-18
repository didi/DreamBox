//
//  DBCBaseTemplateController.h
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/7/28.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBCBaseTemplateController : UIViewController

@property (nonatomic, copy) NSString *templateID;
@property (nonatomic, strong) NSDictionary *extPara;
@end

NS_ASSUME_NONNULL_END
