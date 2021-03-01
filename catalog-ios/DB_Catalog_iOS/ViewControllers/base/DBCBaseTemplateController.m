//
//  DBCBaseTemplateController.m
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/7/28.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#define kDBCTopViewH  44.f
//navibar高度
#define kDBCNaviBarHeight  (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) + CGRectGetHeight(self.navigationController.navigationBar.frame))

#import "DBCBaseTemplateController.h"
#import "DBXTreeView.h"
#import "DBCTopView.h"
#import "DBCCodeView.h"
#import "Masonry.h"



#import "DBCCatalogConstant.h"
@interface DBCBaseTemplateController ()

@property (nonatomic, assign) DBCTopViewSelectedType type;
@property (nonatomic, strong) DBCTopView *topView;
@property (nonatomic, strong) DBCCodeView *codeView;
@property (nonatomic, strong) DBXTreeView *treeView;

@end

@implementation DBCBaseTemplateController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.whiteColor;
    self.type = DBCTopViewSelectedTypeResult;
    [self p_setupSubview];

}

- (void)p_setupSubview {
    
    [self.view addSubview:self.topView];
    self.topView.frame = CGRectMake(0, 0, self.view.frame.size.width, kDBCTopViewH);
     __weak typeof(self) weakSelf = self;
    self.topView.topSwitchClick = ^(DBCTopViewSelectedType type) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.type = type;
        [strongSelf p_switch];
    };
    
    self.treeView = [[DBXTreeView alloc] initWithFrame:CGRectMake(0, kDBCTopViewH, self.view.frame.size.width, self.view.frame.size.height - kDBCTopViewH - kDBCNaviBarHeight)];
    

    
    NSDictionary *ext = [NSDictionary dictionary];
    if (self.extPara) {
        ext = self.extPara;
    }
    
    [self.treeView loadWithTemplateId:self.templateID accessKey:kDBCatalogDemoAccesskey extData:ext completionBlock:^(BOOL successed, NSError * _Nullable error) {
        
    }];
    [self.view addSubview:self.treeView];
    
    // 2.0
    [self.treeView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topView.mas_bottom);
    }];
    
    
    
    self.codeView.frame = self.treeView.frame;
        
    NSString *xmlString = [self p_getXMLString:self.templateID];
    [self.codeView bindCode:xmlString];
    [self.view addSubview:self.codeView];
    
    [self p_switch];
}

- (void)p_switch {
    if (self.type == DBCTopViewSelectedTypeResult) {
        self.treeView.hidden = NO;
        self.codeView.hidden = YES;
    } else {
        self.treeView.hidden = YES;
        self.codeView.hidden = NO;
    }
}


- (NSString *)p_getXMLString:(NSString *)tid {
    
    NSError *error;
    NSBundle *bundle = [NSBundle mainBundle];

    NSString *string = nil;

    NSString *path = [bundle pathForResource:tid ofType:@"xml"];
    string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (string) {
        return string;
    } else {
        return nil;
    }

}

#pragma mark -
- (DBCTopView *)topView {
    if (!_topView) {
        _topView = [[DBCTopView alloc] init];
    }
    return _topView;
}
- (DBCCodeView *)codeView {
    if (!_codeView) {
        _codeView = [[DBCCodeView alloc] init];
    }
    return _codeView;

}


@end
