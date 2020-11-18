//
//  ViewController.m
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/7/27.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import "DBCatalogViewController.h"
#import "DBCActionConstant.h"

#import "DBCHelloWorldController.h"
#import "DBCViewNodeController.h"
#import "DBCActionNodeController.h"
#import "DBCDataNodeController.h"

@interface DBCatalogViewController ()



@end

@implementation DBCatalogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.backgroundColor = UIColor.whiteColor;
    self.title = @"catalog";
    self.dataSource = @[kDBActionStrHelloWorld,
                        kDBActionStr视图节点,
                        kDBActionStr动作节点,
//                        kDBActionStr数据处理,
                        kDBActionStr示范页面].mutableCopy;
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
        
        DBCHelloWorldController *helloVC = [DBCHelloWorldController new];
        helloVC.templateID = @"helloworld";
        vc = helloVC;
        
    } else if ([actionStr isEqualToString:kDBActionStr视图节点]) {
        
        vc = [DBCViewNodeController new];
        
    } else if ([actionStr isEqualToString:kDBActionStr动作节点]) {
        
        vc = [DBCActionNodeController new];
           
    } else if ([actionStr isEqualToString:kDBActionStr数据处理]) {
        
        vc = [DBCDataNodeController new];
           
    } else if ([actionStr isEqualToString:kDBActionStr示范页面]) {
        
        DBCBaseTemplateController *cardetect = [DBCBaseTemplateController new];
        cardetect.templateID = @"cardetect";
        vc = cardetect;
        
    }
    
    if (vc) {
        vc.title = actionStr;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    NSLog(@"%@",actionStr);
}


@end
