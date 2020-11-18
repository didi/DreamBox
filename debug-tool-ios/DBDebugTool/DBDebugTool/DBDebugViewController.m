//
//  ViewController.m
//  DBWSSDemoi
//
//  Created by zhangchu on 2020/6/30.
//  Copyright © 2020 zhangchu. All rights reserved.
//

#import "DBDebugViewController.h"
#import "DBTreeView.h"
#import "DBPreProcess.h"
#import "DBDropListView.h"
#import "DBQRScanVC.h"
#import "DBDebugService.h"
#import "DBPool.h"

static CGFloat DBWSSDemoTopMargin = 30;
static CGFloat DBWSSDemoLeftMargin = 16;
static CGFloat DBWSSDemoHeight = 600;
static CGFloat DBWSSDemoTextFieldWidth = 200;
static CGFloat DBButtonWidth = 100;
static CGFloat DBButtonHeight = 20;
static CGFloat DBButtonMargin = 20;

@interface DBDebugViewController ()


@property (nonatomic,strong) UIButton *scanBtn;
@property (nonatomic,strong) UIButton *connectBtn;
@property (nonatomic,strong) UIButton *refreshBtn;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) DBDropListView *dropList;
@property (nonatomic,strong) DBDropListView *dropList1;
@property (nonatomic,strong) NSArray *selections;
@property (nonatomic,strong) UILabel *accessLabel;
@property (nonatomic,strong) UITextField *accessField;
@property (nonatomic,strong) UILabel *templateLabel;
@property (nonatomic,strong) UITextField *templateField;
@property (nonatomic,strong) UIButton *dropBtn;
@property (nonatomic,strong) UIButton *dropBtn1;
@property (nonatomic,strong) NSDictionary *ATDic;

@end

@implementation DBDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DB PlayGround";
    self.view.backgroundColor = [UIColor whiteColor];
    
//——————————————————————————————————————————————————————————————————//
    [self.view addSubview:self.accessLabel];
    self.accessLabel.frame = CGRectMake(DBButtonMargin, DBWSSDemoTopMargin, DBButtonWidth, 20);
    
    [self.view addSubview:self.accessField];
    self.accessField.frame = CGRectMake(CGRectGetMaxX(self.accessLabel.frame) + 10, DBWSSDemoTopMargin, DBWSSDemoTextFieldWidth, 20);
    
    [self.view addSubview:self.dropList];
    
    [self.view addSubview:self.dropBtn];
    self.dropBtn.frame = CGRectMake(CGRectGetMaxX(self.accessField.frame) + 10, CGRectGetMinY(self.accessField.frame), 44, 20);
    
//——————————————————————————————————————————————————————————————————//
    [self.view addSubview:self.templateLabel];
    self.templateLabel.frame = CGRectMake(DBButtonMargin, CGRectGetMaxY(self.accessLabel.frame) + 10, DBButtonWidth, 20);
    
    [self.view addSubview:self.templateField];
    self.templateField.frame = CGRectMake(CGRectGetMaxX(self.templateLabel.frame) + 10, CGRectGetMinY(self.templateLabel.frame), DBWSSDemoTextFieldWidth, 20);
    
    [self.view addSubview:self.dropList1];
    
    [self.view addSubview:self.dropBtn1];
    self.dropBtn1.frame = CGRectMake(CGRectGetMaxX(self.templateField.frame) + 10, CGRectGetMinY(self.templateField.frame), 44, 20);
    
    [self.view addSubview:self.dropList1];
    self.dropList.frame = CGRectMake(DBButtonMargin, 100, DBButtonWidth, 0);
 

//——————————————————————————————————————————————————————————————————//
    self.scanBtn.frame = CGRectMake(DBButtonMargin, CGRectGetMaxY(self.templateLabel.frame) + 10, DBButtonWidth, DBButtonHeight);
    [self.view addSubview:self.scanBtn];

    self.refreshBtn.frame = CGRectMake(DBButtonMargin*2 + DBButtonWidth, CGRectGetMinY(self.scanBtn.frame), DBButtonWidth, DBButtonHeight);
    [self.view addSubview:self.refreshBtn];

    self.textField.frame = CGRectMake(DBButtonMargin, CGRectGetMaxY(self.refreshBtn.frame) + 10, self.view.frame.size.width - 2*DBButtonMargin - 120, 20);
    [self.view addSubview:self.textField];

    self.connectBtn.frame = CGRectMake(CGRectGetMaxX(self.textField.frame) + DBButtonMargin, CGRectGetMinY(self.textField.frame), 100, DBButtonHeight);
    [self.view addSubview:self.connectBtn];
    
    [self setUpDBViewWithMetaData:nil ext:nil];
    
    [self loadDBData];
}

- (void)loadDBData{
    _ATDic = [[DBPool shareDBPool] getAccessKeyAndTidDict];
    NSArray *AccessKeyArr = [_ATDic allKeys];
    [self.dropList setSelections:AccessKeyArr];
}

#pragma mark - EventResponse
- (void)scanQRCode{
    DBQRScanVC *scanVC = [[DBQRScanVC alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)refresh{
    [[DBDebugService shareInstance] refresh];
}

- (void)bind {
    
    NSString *accessKey = self.accessField.text;
    NSString *templateId = self.templateField.text;
    if(!(accessKey.length > 0 && templateId.length > 0)){
        [self alertWithMessage:@"请输入accessID和templateID"];
        return;
    }
    
    if(!(self.textField.text.length > 0)){
        [self alertWithMessage:@"WS服务地址为空"];
        return;
    }

    if(self.textField.text.length > 0){
        DBTreeView *view = [[DBPool shareDBPool] getDBViewWithTid:templateId andAccessKey:accessKey];
        if(!view){
            [self alertWithMessage:@"取不到与当前accessKey、templateId对应的DBView"];
        }
        //此处DBView应该由DBCore提供，根据accessID和templateID获取
        [DBDebugService shareInstance].dbView = view;
        [[DBDebugService shareInstance] bindWithWss:self.textField.text];
        if(self.navigationController){
            [self.navigationController popViewControllerAnimated:YES];
        } else {
           [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
}

- (void)selectAccess{
    [self foldDropList1];
    if(![self.dropList isShown]){
        [self.dropList showWithButton:self.dropBtn];
    } else {
        [self.dropList dismissWithButton:self.dropBtn];
    }
}

- (void)selectTemplate{
    [self foldDropList];
    if(![self.dropList1 isShown]){
        [self.dropList1 showWithButton:self.dropBtn1];
    } else {
        [self.dropList1 dismissWithButton:self.dropBtn1];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self foldDropList];
}


- (void)foldDropList{
    if([self.dropList isShown]){
        [self.dropList dismissWithButton:self.dropBtn];
    }
}

- (void)foldDropList1{
    if([self.dropList1 isShown]){
        [self.dropList1 dismissWithButton:self.dropBtn1];
    }
}

- (void)setUpDBViewWithMetaData:(NSString *)data ext:(NSDictionary *)ext {
    if([DBDebugService shareInstance].dbView){
        [[DBDebugService shareInstance].dbView removeFromSuperview];
        [DBDebugService shareInstance].dbView = nil;
    }
    
    if(!(data.length > 0)){
        //首次
        [DBDebugService shareInstance].dbView = [[DBTreeView alloc] init];
        [self.view addSubview:[DBDebugService shareInstance].dbView];
        [DBDebugService shareInstance].dbView.layer.borderWidth = 0.5;
        [[DBDebugService shareInstance].dbView loadWithTemplateId:@"hellodb" accessKey:@"test" extData:nil completionBlock:^(BOOL successed, NSError * _Nullable error) {
            
        }];
    } else {
        //刷新，暂无刷新接口，用重建代替
        [DBDebugService shareInstance].dbView = [[DBTreeView alloc] initWithData:data extMeta:ext accessKey:@"test"];
        [self.view addSubview:[DBDebugService shareInstance].dbView];
    }
    
    [DBDebugService shareInstance].dbView.frame = CGRectMake(DBWSSDemoLeftMargin, CGRectGetMaxY(self.textField.frame) + 10, self.view.frame.size.width - 2*DBWSSDemoLeftMargin, DBWSSDemoHeight);
    [[DBDebugService shareInstance].dbView reloadTreeView];
}

- (void)alertWithMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}

#pragma mark - getter/setter
- (UIButton *)scanBtn{
    if(!_scanBtn){
        _scanBtn = [UIButton new];
        _scanBtn.backgroundColor = [UIColor lightGrayColor];
        [_scanBtn setTitle:@"扫码" forState:UIControlStateNormal];
        [_scanBtn addTarget:self action:@selector(scanQRCode) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanBtn;
}

- (UIButton *)refreshBtn{
    if(!_refreshBtn){
        _refreshBtn = [UIButton new];
        _refreshBtn.backgroundColor = [UIColor lightGrayColor];
        [_refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

- (UIButton *)connectBtn{
    if(!_connectBtn){
        _connectBtn = [UIButton new];
        _connectBtn.backgroundColor = [UIColor lightGrayColor];
        [_connectBtn setTitle:@"绑定" forState:UIControlStateNormal];
        [_connectBtn addTarget:self action:@selector(bind) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectBtn;;
}

- (UITextField *)textField {
    if(!_textField){
        _textField = [[UITextField alloc] init];
        _textField.placeholder = @"输入WS服务地址";
        _textField.layer.borderWidth = 0.5;
    }
    return _textField;
}

- (UILabel *)accessLabel {
    if(!_accessLabel){
        _accessLabel = [UILabel new];
        _accessLabel.text = @"accessID:";
        _accessLabel.textAlignment = NSTextAlignmentRight;
    }
    return _accessLabel;
}

- (UITextField *)accessField {
    if(!_accessField){
        _accessField = [[UITextField alloc] init];
        _accessField.placeholder = @"输或选择accessID";
        _accessField.layer.borderWidth = 0.5;
        _accessLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return _accessField;
}

- (UILabel *)templateLabel {
    if(!_templateLabel){
        _templateLabel = [UILabel new];
        _templateLabel.text = @"templateID:";
        _templateLabel.textAlignment = NSTextAlignmentRight;
    }
    return _templateLabel;
}

- (UITextField *)templateField {
    if(!_templateField){
        _templateField = [[UITextField alloc] init];
        _templateField.placeholder = @"请输入或选择templateID";
        _templateField.layer.borderWidth = 0.5;
    }
    return _templateField;
}

- (DBDropListView *)dropList {
    if(!_dropList) {
        _dropList = [[DBDropListView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.accessField.frame), CGRectGetMaxY(self.accessField.frame), DBWSSDemoTextFieldWidth, 0) selections:nil selectBlock:^(NSInteger index, NSString *selectedId) {
            _accessField.text = selectedId;
            NSArray *tids = [_ATDic objectForKey:selectedId];
            [self.dropList1 setSelections:tids];
            [self.dropList dismissWithButton:self.dropBtn];
        }];
        _dropList.layer.borderWidth = 0.5;
        _dropList.backgroundColor = [UIColor whiteColor];
    }
    return _dropList;
}

- (UIButton *)dropBtn{
    if(!_dropBtn){
        _dropBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_dropBtn setTitle:@"选择" forState:UIControlStateNormal];
        [_dropBtn addTarget:self action:@selector(selectAccess) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dropBtn;
}

- (DBDropListView *)dropList1 {
    if(!_dropList1) {
        _dropList1 = [[DBDropListView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.templateField.frame), CGRectGetMaxY(self.templateField.frame), DBWSSDemoTextFieldWidth, 0) selections:nil selectBlock:^(NSInteger index, NSString *selectedId) {
            _templateField.text = selectedId;
            [self.dropList1 dismissWithButton:self.dropBtn];
        }];
        _dropList1.layer.borderWidth = 0.5;
        _dropList1.backgroundColor = [UIColor whiteColor];
    }
    return _dropList1;
}

- (UIButton *)dropBtn1{
    if(!_dropBtn1){
        _dropBtn1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [_dropBtn1 setTitle:@"选择" forState:UIControlStateNormal];
        [_dropBtn1 addTarget:self action:@selector(selectTemplate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dropBtn1;
}




@end
