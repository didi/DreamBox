//
//  DBCViewNodeController.m
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/7/27.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import "DBCViewNodeController.h"
#import "DBCBaseTemplateController.h"

@interface DBCViewNodeController ()

@end

@implementation DBCViewNodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = @[
                        kDBActionStr页面布局,
                        kDBActionStr文本按钮,
                        kDBActionStr图片,
                        kDBActionStr占位,
                        kDBActionStr进度条,
                        kDBActionStrLoading,
                        kDBActionStr列表,
                        kDBActionStr流式瀑布,
                        ].mutableCopy;
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
    
    if ([actionStr isEqualToString:kDBActionStr文本按钮]) {
        
        vc.templateID = @"text";
        
    } else if ([actionStr isEqualToString:kDBActionStr占位]) {
        
        vc.templateID = @"view";
        
    } else if ([actionStr isEqualToString:kDBActionStr进度条]) {
        
        vc.templateID = @"progress";
           
    } else if ([actionStr isEqualToString:kDBActionStr流式瀑布]) {
        
        vc.templateID = @"flow";
        vc.extPara = [self ext:@"flow"];
           
    } else if ([actionStr isEqualToString:kDBActionStr图片]) {
        
        vc.templateID = @"image";
       
    } else if ([actionStr isEqualToString:kDBActionStrLoading]) {
        
        vc.templateID = @"loading";
           
    } else if ([actionStr isEqualToString:kDBActionStr列表]) {
        
        vc.templateID = @"list";
        vc.extPara = [self ext:@"list"];
        
    } else if ([actionStr isEqualToString:kDBActionStr页面布局]) {
        
        vc.templateID = @"layout";
    }
    
    if (vc) {
        vc.title = actionStr;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    NSLog(@"%@",actionStr);
}

- (NSDictionary *)ext:(NSString*)name {
               
    NSString *string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                                            pathForResource:name ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}
@end
