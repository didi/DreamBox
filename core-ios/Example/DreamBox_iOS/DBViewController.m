//
//  DBViewController.m
//  DreamBox_iOS
//
//  Created by fangshaosheng on 05/26/2020.
//  Copyright (c) 2020 fangshaosheng. All rights reserved.
//

#import "DBViewController.h"

#import "DBXTreeView.h"
#import "DBXParser.h"
#import "DBXService.h"
#import "DBXDefaultWrapper.h"
#import "DBXPreProcess.h"
#import "DBXService.h"
#import "DBDebugService.h"
#import "DBXFactory.h"
#import "Masonry.h"

@interface DBViewController ()

@property (nonatomic,strong) DBXTreeView *dbView;

@property (nonatomic, strong) DBXTreeView *DBResView;

@property (nonatomic, strong) DBXTreeView *DBDiffView;

@end

@implementation DBViewController

- (void)viewDidLoad {
    [self wrapperTest];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (NSDictionary *)pareseExt {
    NSString *mockDataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mock_Data" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [mockDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}

- (void)wrapperTest {
    NSString *mockDataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tmp1" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];

    [[DBXFactory sharedInstance] registViewClass:NSClassFromString(@"DBAddCartButton") byType:@"AddCart"];
    [[DBXFactory sharedInstance] registModelClass:NSClassFromString(@"DBViewModel") byType:@"AddCart"];
    
    
    DBXTreeView *dbView = [[DBXTreeView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    self.dbView = [dbView initWithJsonSting:mockDataString extMeta:nil accessKey:@"DEMO" tid:@"1"];
    [self.view addSubview:self.dbView];
    self.dbView.frame = CGRectMake(0, 100, self.dbView.frame.size.width, self.dbView.frame.size.height);
}

@end 
