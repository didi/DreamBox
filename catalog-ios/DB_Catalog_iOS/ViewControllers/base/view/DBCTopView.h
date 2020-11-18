//
//  DBCTopView.h
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/8/4.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, DBCTopViewSelectedType) {
    DBCTopViewSelectedTypeResult,
    DBCTopViewSelectedTypeCode
};
NS_ASSUME_NONNULL_BEGIN

@interface DBCTopView : UIView

@property (nonatomic, copy) void(^topSwitchClick)(DBCTopViewSelectedType type);


@end

NS_ASSUME_NONNULL_END
