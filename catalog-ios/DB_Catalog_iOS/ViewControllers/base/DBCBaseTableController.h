//
//  DBCBaseTableController.h
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/7/27.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCActionConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface DBCBaseTableController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)setupSubview;

@end

NS_ASSUME_NONNULL_END
