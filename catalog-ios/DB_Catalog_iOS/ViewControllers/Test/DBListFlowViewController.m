//
//  DBListFlowViewController.m
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/11/30.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import "DBListFlowViewController.h"
#import "DBListFlowCell.h"
@interface DBListFlowViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;

@end

@implementation DBListFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.table = [[UITableView alloc] init];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table registerClass:DBListFlowCell.class forCellReuseIdentifier:@"flow"];
    [self.view addSubview:self.table];
    self.view.backgroundColor = UIColor.grayColor;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.table.frame = self.view.bounds;
}
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DBListFlowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"flow"];
    if (!cell) {
        cell = [[DBListFlowCell alloc] init];
    }
    [cell bindData:nil];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}


@end
