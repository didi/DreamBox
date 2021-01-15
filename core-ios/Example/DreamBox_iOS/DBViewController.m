//
//  DBViewController.m
//  DreamBox_iOS
//
//  Created by fangshaosheng on 05/26/2020.
//  Copyright (c) 2020 fangshaosheng. All rights reserved.
//

#import "DBViewController.h"

#import "DBTreeView.h"
#import "DBParser.h"
#import "DBService.h"
#import "DBDefaultWrapper.h"
#import "DBPreProcess.h"
#import "DBService.h"
#import "DBDebugService.h"
#import "DBFactory.h"
#import "DBMyViewModel.h"
#import "DBMyView.h"
#import "DBMyAction.h"
#import "Masonry.h"

@interface DBViewController ()

@property (nonatomic,strong) DBTreeView *dbView;

@property (nonatomic, strong) DBTreeView *DBResView;

@property (nonatomic, strong) DBTreeView *DBDiffView;

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
    
    self.dbView = [[DBTreeView alloc] initWithJsonSting:mockDataString extMeta:nil accessKey:@"DEMO" tid:@"1"];
    [self.view addSubview:self.dbView];
    self.dbView.frame = CGRectMake(0, 100, self.dbView.frame.size.width, self.dbView.frame.size.height);
}

@end 
