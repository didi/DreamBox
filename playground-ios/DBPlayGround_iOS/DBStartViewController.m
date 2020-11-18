//
//  ViewController.m
//  DBWSSDemoi
//
//  Created by zhangchu on 2020/6/30.
//  Copyright © 2020 zhangchu. All rights reserved.
//

#import "DBStartViewController.h"
#import "DBWssTest.h"
#import "DBTreeView.h"
#import "DBPreProcess.h"
#import "DBQRScanVC.h"
#import "Masonry.h"
#import "NSString+DBExtends.h"

static CGFloat DBWSSDemoHeight = 600;
static CGFloat DBButtonHeight = 25;
static CGFloat DBButtonMargin = 10;
static CGFloat DBVerticalMargin = 10;

@interface DBStartViewController ()<DBWSSDelegate>

@property (nonatomic,strong) DBTreeView *dbView;
@property (nonatomic,strong) UIButton *scanBtn;
@property (nonatomic,strong) UIButton *connectBtn;
@property (nonatomic,strong) UIButton *refreshBtn;
@property (nonatomic,strong) NSString *currentData;
@property (nonatomic,strong) UITextField *textField;

@end

@implementation DBStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithRed:0xF7/255.0 green:0xF7/255.0 blue:0xF9/255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"DB PlayGround";
    // Do any additional setup after loading the view.
    [DBWssTest shareInstance].delegate = self;
   
    self.scanBtn.frame = CGRectMake(DBButtonMargin, 100, (self.view.frame.size.width - 3 * DBButtonMargin)/2, DBButtonHeight);
    [self.view addSubview:self.scanBtn];
    
    self.refreshBtn.frame = CGRectMake(CGRectGetMaxX(self.scanBtn.frame) + DBButtonMargin, CGRectGetMinY(self.scanBtn.frame), (self.view.frame.size.width - 3 * DBButtonMargin)/2, DBButtonHeight);
    [self.view addSubview:self.refreshBtn];
    
    self.textField.frame = CGRectMake(DBButtonMargin, CGRectGetMaxY(self.scanBtn.frame) + DBVerticalMargin, self.view.frame.size.width - 2*DBButtonMargin - 120, DBButtonHeight);
    [self.view addSubview:self.textField];
    
    self.connectBtn.frame = CGRectMake(CGRectGetMaxX(self.textField.frame) + DBButtonMargin, CGRectGetMinY(self.textField.frame), self.view.frame.size.width - 3*DBButtonMargin - self.textField.frame.size.width, DBButtonHeight);
    [self.view addSubview:self.connectBtn];
    
    [self setUpDBViewWithMetaData:nil ext:nil];
}

#pragma mark - private
- (void)refreshViewWithTemplateData:(NSString *)data{
    _currentData = data;
    [self setUpDBViewWithMetaData:data ext:nil];
}

- (void)refreshViewWithExtData:(NSString *)extData{
    NSDictionary *extDict = [extData db_toJSONDictionary];
    [self.dbView bindExtensionMetaData:extDict];
}

- (void)setUpDBViewWithMetaData:(NSString *)data ext:(NSDictionary *)ext {
    
    if(!self.dbView){
        self.dbView = [[DBTreeView alloc] init];
        [self.view addSubview:self.dbView];
        self.dbView.backgroundColor = [UIColor whiteColor];
        self.dbView.layer.borderWidth = 0.5;
        self.dbView.layer.borderColor = [UIColor grayColor].CGColor;
        [self.dbView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(DBButtonMargin);
            make.top.mas_equalTo(CGRectGetMaxY(self.textField.frame) + DBVerticalMargin);
            make.width.mas_equalTo(self.view.frame.size.width - 2*DBButtonMargin);
            make.height.mas_equalTo(DBWSSDemoHeight);
        }];
    }
    
    if(!(data.length > 0)){
        //首次
        [self.dbView loadWithTemplateId:@"hellodb" accessKey:@"test" extData:nil completionBlock:^(BOOL successed, NSError * _Nullable error) {
        }];
    } else {
        //刷新，暂无刷新接口，用重建代替
        [self.dbView reloadWithData:data extMeta:ext];
    }
    
    self.dbView.frame = CGRectMake(DBButtonMargin, CGRectGetMaxY(self.textField.frame) + DBVerticalMargin, self.view.frame.size.width - 2*DBButtonMargin, DBWSSDemoHeight);

    [self.dbView reloadTreeView];
}

- (void)scanQRCode{
    DBQRScanVC *scanVC = [[DBQRScanVC alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)refresh {
    [self.dbView reloadTreeView];
}

- (void)bind {
    if(self.textField.text.length > 0){
        [[DBWssTest shareInstance] openWSSConnectWithIPStr:self.textField.text];
    }
}


#pragma mark - getter/setter
- (UIButton *)scanBtn{
    if(!_scanBtn){
        _scanBtn = [UIButton new];
        _scanBtn.layer.borderWidth = 0.5;
        _scanBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _scanBtn.backgroundColor = [UIColor colorWithRed:0xF7/255.0 green:0xF7/255.0 blue:0xF9/255.0 alpha:1.0];
//        _scanBtn.backgroundColor = [UIColor whiteColor];
        [_scanBtn setTitle:@"扫码" forState:UIControlStateNormal];
        [_scanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_scanBtn addTarget:self action:@selector(scanQRCode) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanBtn;
}

- (UIButton *)refreshBtn{
    if(!_refreshBtn){
        _refreshBtn = [UIButton new];
        _refreshBtn.layer.borderWidth = 0.5;
        _refreshBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _refreshBtn.backgroundColor = [UIColor colorWithRed:0xF7/255.0 green:0xF7/255.0 blue:0xF9/255.0 alpha:1.0];
//        _refreshBtn.backgroundColor = [UIColor whiteColor];
        [_refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

- (UIButton *)connectBtn{
    if(!_connectBtn){
        _connectBtn = [UIButton new];
        _connectBtn.layer.borderWidth = 0.5;
        _connectBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _connectBtn.backgroundColor = [UIColor colorWithRed:0xF7/255.0 green:0xF7/255.0 blue:0xF9/255.0 alpha:1.0];
//        _connectBtn.backgroundColor = [UIColor whiteColor];
        [_connectBtn setTitle:@"绑定" forState:UIControlStateNormal];
        [_connectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_connectBtn addTarget:self action:@selector(bind) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectBtn;;
}

- (UITextField *)textField {
    if(!_textField){
        _textField = [[UITextField alloc] init];
        _textField.placeholder = @"请输入WS服务地址";
        _textField.layer.borderWidth = 0.5;
        _textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textField.backgroundColor = [UIColor whiteColor];
    }
    return _textField;
}

#pragma mark - test data
- (NSDictionary *)pareseExt {
    NSString *mockDataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CTR_EXT" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [mockDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}

- (NSString *)dblStr {
    return @"fe4dcff2cee77b333c899dfcf95fcd8a000100000000000000000000ewogImRibCI6IHsKICAibWV0YSI6IHt9LAogICJyZW5kZXIiOiBbCiAgIHsKICAgICJzcmMiOiAiJHtleHQuYmdfaW1hZ2V9IiwKICAgICJ3aWR0aCI6ICIwZHAiLAogICAgImhlaWdodCI6ICJkcCIsCiAgICAidHlwZSI6ICJpbWFnZSIsCiAgICAib25DbGljayI6IHsKICAgICAibmF2IjogewogICAgICAic2NoZW1hIjogIiR7ZXh0LnRhcmdldF91cmx9IgogICAgIH0sCiAgICAgInRyYWNlIjogewogICAgICAia2V5IjogImJlYXRfeF95dW5nIiwKICAgICAgImF0dHIiOiBbCiAgICAgICB7CiAgICAgICAgImtleSI6ICJ0eXBlIiwKICAgICAgICAidmFsdWUiOiAiMSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJta19pZCIsCiAgICAgICAgInZhbHVlIjogIiR7ZXh0Lm1rX2lkfSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJjaGFubmVsX2lkIiwKICAgICAgICAidmFsdWUiOiAiJHtleHQubWtfaWR9IgogICAgICAgfQogICAgICBdCiAgICAgfQogICAgfSwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInRvcFRvVG9wIjogIjAiLAogICAgInJpZ2h0VG9SaWdodCI6ICIwIiwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmxlZnRfdGl0bGUubWVzc2FnZX0iLAogICAgIm1hcmdpbkxlZnQiOiAiMTZkcCIsCiAgICAibWFyZ2luVG9wIjogIjMyZHAiLAogICAgInNpemUiOiAiMTZkcCIsCiAgICAiY29sb3IiOiAiIzIxMkUzMyIsCiAgICAic3R5bGUiOiAiYm9sZCIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJpZCI6ICIxIiwKICAgICJ0b3BUb1RvcCI6ICIwIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQubGVmdF9jb250ZW50Lm1lc3NhZ2V9IiwKICAgICJtYXJnaW5Ub3AiOiAiNmRwIiwKICAgICJzaXplIjogIjEyZHAiLAogICAgImNvbG9yIjogIiM5NDlGQTUiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAiaWQiOiAiMiIsCiAgICAibGVmdFRvTGVmdCI6ICIxIiwKICAgICJ0b3BUb0JvdHRvbSI6ICIxIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmxlZnRfY29udGVudF9hcnJvd30iLAogICAgIndpZHRoIjogIjRkcCIsCiAgICAiaGVpZ2h0IjogIjhkcCIsCiAgICAibWFyZ2luTGVmdCI6ICI0ZHAiLAogICAgInR5cGUiOiAiaW1hZ2UiLAogICAgImxlZnRUb1JpZ2h0IjogIjIiLAogICAgInRvcFRvVG9wIjogIjIiLAogICAgImJvdHRvbVRvQm90dG9tIjogIjIiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQucmlnaHRfaW1hZ2V9IiwKICAgICJ3aWR0aCI6ICIxMDBkcCIsCiAgICAiaGVpZ2h0IjogIjkwZHAiLAogICAgIm1hcmdpblRvcCI6ICIxMGRwIiwKICAgICJtYXJnaW5SaWdodCI6ICIxMWRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJyaWdodFRvUmlnaHQiOiAiMCIsCiAgICAidG9wVG9Ub3AiOiAiMCIKICAgfSwKICAgewogICAgImJhY2tncm91bmRDb2xvciI6ICIke2V4dC5hY3Rpb25fYXJlYS5iZ19jb2xvcn0iLAogICAgIndpZHRoIjogIjBkcCIsCiAgICAiaGVpZ2h0IjogIjQ0ZHAiLAogICAgInR5cGUiOiAidmlldyIsCiAgICAib25DbGljayI6IHsKICAgICAibmF2IjogewogICAgICAic2NoZW1hIjogIiR7ZXh0LmFjdGlvbl9hcmVhLnRhcmdldF91cmx9IgogICAgIH0sCiAgICAgInRyYWNlIjogewogICAgICAia2V5IjogImJlYXRfeF95dW5nIiwKICAgICAgImF0dHIiOiBbCiAgICAgICB7CiAgICAgICAgImtleSI6ICJ0eXBlIiwKICAgICAgICAidmFsdWUiOiAiMSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJta19pZCIsCiAgICAgICAgInZhbHVlIjogIiR7ZXh0Lm1rX2lkfSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJjaGFubmVsX2lkIiwKICAgICAgICAidmFsdWUiOiAiJHtleHQubWtfaWR9IgogICAgICAgfQogICAgICBdCiAgICAgfQogICAgfSwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInJpZ2h0VG9MZWZ0IjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQuYWN0aW9uX2FyZWEuYXJyb3d9IiwKICAgICJtYXJnaW5SaWdodCI6ICIyM2RwIiwKICAgICJtYXJnaW5Cb3R0b20iOiAiMTdkcCIsCiAgICAid2lkdGgiOiAiMTVkcCIsCiAgICAiaGVpZ2h0IjogIjlkcCIsCiAgICAidHlwZSI6ICJpbWFnZSIsCiAgICAiaWQiOiAiMyIsCiAgICAicmlnaHRUb1JpZ2h0IjogIjAiLAogICAgImJvdHRvbVRvQm90dG9tIjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQuYWN0aW9uX2FyZWEuYnRuX3RleHR9IiwKICAgICJtYXJnaW5Cb3R0b20iOiAiMTRkcCIsCiAgICAibWFyZ2luUmlnaHQiOiAiNGRwIiwKICAgICJjb2xvciI6ICIjMjEyRTMzIiwKICAgICJzaXplIjogIjE0ZHAiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAicmlnaHRUb0xlZnQiOiAiMyIsCiAgICAiYm90dG9tVG9Cb3R0b20iOiAiMCIKICAgfSwKICAgewogICAgInNyYyI6ICIke2V4dC5hY3Rpb25fYXJlYS5kZXNjLm1lc3NhZ2V9IiwKICAgICJjb2xvciI6ICIjMjEyRTMzIiwKICAgICJzaXplIjogIjEyZHAiLAogICAgIm1hcmdpbkxlZnQiOiAiMTZkcCIsCiAgICAibWFyZ2luQm90dG9tIjogIjE0ZHAiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAiYm90dG9tVG9Cb3R0b20iOiAiMCIsCiAgICAibGVmdFRvTGVmdCI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmNvcm5lcl9pbmNvX2JnfSIsCiAgICAibWFyZ2luQm90dG9tIjogIjJkcCIsCiAgICAidHlwZSI6ICJpbWFnZSIsCiAgICAibGVmdFRvTGVmdCI6ICIxIiwKICAgICJib3R0b21Ub1RvcCI6ICIxIgogICB9CiAgXQogfQp9";
}
@end
