//
//  DBCDataNodeController.m
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/7/27.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import "DBCDataNodeController.h"

@interface DBCDataNodeController ()

@end

@implementation DBCDataNodeController

- (void)viewDidLoad {
    [super viewDidLoad];
       
    self.dataSource = @[].mutableCopy;
    [self setupSubview];
    [self.tableView reloadData];
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *actionStr = [self.dataSource objectAtIndex:indexPath.row];
    
    UIViewController *vc = nil;
    
    
    if ([actionStr isEqualToString:kDBActionStrHelloWorld]) {
        
        
        
    } else if ([actionStr isEqualToString:kDBActionStr视图节点]) {
        
        
        
    } else if ([actionStr isEqualToString:kDBActionStr动作节点]) {
        
       
           
    } else if ([actionStr isEqualToString:kDBActionStr数据处理]) {
        
        
           
    } else if ([actionStr isEqualToString:kDBActionStr示范页面]) {
        
        
        
    }
    
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    NSLog(@"%@",actionStr);
}
@end
