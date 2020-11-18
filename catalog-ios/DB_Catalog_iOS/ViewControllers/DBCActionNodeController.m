//
//  DBCActionNodeController.m
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/7/27.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import "DBCActionNodeController.h"
#import "DBCBaseTemplateController.h"
@interface DBCActionNodeController ()

@end

@implementation DBCActionNodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    self.dataSource = @[kDBActionStr日志,
                        kDBActionStr埋点,
                        kDBActionStr缓存,
                        kDBActionStr弹窗,
                        kDBActionStr关闭页面,
                        kDBActionStr网络,
                        kDBActionStr跳转,
                        kDBActionStr数据变更,
                        kDBActionStrToast,
                        kDBActionStrAliasAndInvoke].mutableCopy;
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
    
    DBCBaseTemplateController *vc = [DBCBaseTemplateController new];
    if ([actionStr isEqualToString:kDBActionStr日志]) {
        
        vc.templateID = @"log";
        
    } else if ([actionStr isEqualToString:kDBActionStr埋点]) {
        
        vc.templateID = @"trace";
           
    } else if ([actionStr isEqualToString:kDBActionStr缓存]) {
        
        vc.templateID = @"storage";
           
    } else if ([actionStr isEqualToString:kDBActionStr弹窗]) {
        
        vc.templateID = @"dialog";
        
    } else if ([actionStr isEqualToString:kDBActionStr关闭页面]) {
        
        vc.templateID = @"closePage";
        
    } else if ([actionStr isEqualToString:kDBActionStr网络]) {
        
        vc.templateID = @"net";
        
    } else if ([actionStr isEqualToString:kDBActionStr跳转]) {

        vc.templateID = @"schema";

    } else if ([actionStr isEqualToString:kDBActionStr数据变更]) {
        
        vc.templateID = @"changemeta";
        
    } else if ([actionStr isEqualToString:kDBActionStrToast]) {
        
        vc.templateID = @"toast";
        
    } else if ([actionStr isEqualToString:kDBActionStrAliasAndInvoke]) {
        
        vc.templateID = @"alias";
    }
    
    if (vc) {
        vc.title = actionStr;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    NSLog(@"%@",actionStr);
}

@end
