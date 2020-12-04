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
}

- (NSDictionary *)pareseExt {
    NSString *mockDataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mock_Data" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [mockDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}

- (void)wrapperTest {
    NSString *mockDataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"safe_task" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    
    self.dbView = [[DBTreeView alloc] initWithJsonSting:mockDataString extMeta:[self pareseExt] accessKey:@"DEMO" tid:nil];
    [self.view addSubview:self.dbView];
    [self.dbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

@end 
