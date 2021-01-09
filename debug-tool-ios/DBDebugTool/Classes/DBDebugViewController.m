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
#import "Masonry.h"
#import "NSString+DBExtends.h"

static CGFloat DBWSSDemoTopMargin = 30;
static CGFloat DBWSSDemoLeftMargin = 16;
static CGFloat DBWSSDemoHeight = 600;
static CGFloat DBButtonWidth = 44;
static CGFloat DBButtonHeight = 30;
static CGFloat DBButtonMargin = 20;

@interface DBDebugViewController ()


@property (nonatomic,strong) UIButton *scanBtn;
@property (nonatomic,strong) UIButton *connectBtn;
@property (nonatomic,strong) UIButton *refreshBtn;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) DBDropListView *dropList;
@property (nonatomic,strong) DBDropListView *dropList1;
@property (nonatomic,strong) NSArray *selections;
@property (nonatomic,strong) UITextField *accessField;
@property (nonatomic,strong) UITextField *templateField;
@property (nonatomic,strong) UIButton *dropBtn;
@property (nonatomic,strong) UIButton *dropBtn1;
@property (nonatomic,strong) NSDictionary *ATDic;
@property (nonatomic,strong) DBTreeView *dbView;

@end

@implementation DBDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DB PlayGround";
    self.view.backgroundColor = [UIColor whiteColor];
    
//——————————————————————————————————————————————————————————————————//
    [self.view addSubview:self.accessField];
    self.accessField.frame = CGRectMake(DBButtonMargin, DBWSSDemoTopMargin, self.view.frame.size.width - 3*DBButtonMargin - DBButtonWidth, DBButtonHeight);
    
    [self.view addSubview:self.dropList];
    [self.view addSubview:self.dropBtn];
    self.dropBtn.frame = CGRectMake(CGRectGetMaxX(self.accessField.frame) + 10, CGRectGetMinY(self.accessField.frame), 44, DBButtonHeight);
    
//——————————————————————————————————————————————————————————————————//

    [self.view addSubview:self.templateField];
    self.templateField.frame = CGRectMake(DBButtonMargin, CGRectGetMaxY(self.accessField.frame) + 10, self.view.frame.size.width - 3*DBButtonMargin - DBButtonWidth, DBButtonHeight);

    [self.view addSubview:self.dropList1];
    [self.view addSubview:self.dropBtn1];
    self.dropBtn1.frame = CGRectMake(CGRectGetMaxX(self.templateField.frame) + 10, CGRectGetMinY(self.templateField.frame), 44, DBButtonHeight);
    
//——————————————————————————————————————————————————————————————————//
    self.textField.frame = CGRectMake(DBButtonMargin, CGRectGetMaxY(self.dropBtn1.frame) + 10, self.view.frame.size.width - 3*DBButtonMargin - DBButtonWidth, DBButtonHeight);
    
    [self.view addSubview:self.textField];
    [self.view addSubview:self.scanBtn];
    self.scanBtn.frame = CGRectMake(CGRectGetMaxX(self.textField.frame) + 10, CGRectGetMinY(self.textField.frame), 44, DBButtonHeight);
    
//——————————————————————————————————————————————————————————————————//
    self.connectBtn.frame = CGRectMake(DBButtonMargin, CGRectGetMaxY(self.textField.frame) + 10, 150, 50);
    [self.view addSubview:self.connectBtn];

    self.refreshBtn.frame = CGRectMake(CGRectGetMaxX(self.connectBtn.frame), CGRectGetMinY(self.connectBtn.frame), 150, 50);
    [self.view addSubview:self.refreshBtn];
//——————————————————————————————————————————————————————————————————//
    
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
    self.dbView = [DBDebugService shareInstance].dbView;
    if(!self.dbView){
        self.dbView = [[DBTreeView alloc] init];
        [self.view addSubview:self.dbView];
        self.dbView.backgroundColor = [UIColor whiteColor];
        self.dbView.layer.borderWidth = 0.5;
        self.dbView.layer.borderColor = [UIColor grayColor].CGColor;
    }
    
    if(!(data.length > 0)){
        //首次
        [self.dbView loadWithTemplateId:@"hellodb" accessKey:@"test" extData:nil completionBlock:^(BOOL successed, NSError * _Nullable error) {
        }];
    } else {
        //刷新，暂无刷新接口，用重建代替
        [self.dbView reloadWithData:data extMeta:ext];
    }
    
    self.dbView.frame = CGRectMake(DBButtonMargin, CGRectGetMaxY(self.textField.frame) + 10, self.view.frame.size.width - 2*DBWSSDemoLeftMargin, DBWSSDemoHeight);

    [self.dbView reloadTreeView];
}

- (void)alertWithMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}

#pragma mark - getter/setter
- (UIButton *)scanBtn{
    if(!_scanBtn){
        _scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanBtn setTitle:@"扫码" forState:UIControlStateNormal];
        [_scanBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_scanBtn addTarget:self action:@selector(scanQRCode) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanBtn;
}

- (UIButton *)refreshBtn{
    if(!_refreshBtn){
        _refreshBtn = [UIButton new];
        _refreshBtn.backgroundColor = [UIColor whiteColor];
        _refreshBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _refreshBtn.layer.borderWidth = 1;
        [_refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

- (UIButton *)connectBtn{
    if(!_connectBtn){
        _connectBtn = [UIButton new];
        _connectBtn.backgroundColor = [UIColor whiteColor];
        _connectBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _connectBtn.layer.borderWidth = 1;
        [_connectBtn setTitle:@"绑定" forState:UIControlStateNormal];
        [_connectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_connectBtn addTarget:self action:@selector(bind) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectBtn;;
}

- (UITextField *)textField {
    if(!_textField){
        _textField = [[UITextField alloc] init];
        _textField.placeholder = @"输入或扫码webSocket服务地址";
        _textField.layer.borderWidth = 0.5;
    }
    return _textField;
}


- (UITextField *)accessField {
    if(!_accessField){
        _accessField = [[UITextField alloc] init];
        _accessField.placeholder = @"请输入或选择accessKey";
        _accessField.layer.borderWidth = 0.5;
    }
    return _accessField;
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
        typeof(self) __weak weakSelf = self;
        _dropList = [[DBDropListView alloc] initWithFrame:CGRectMake(CGRectGetMinX(weakSelf.accessField.frame), CGRectGetMaxY(weakSelf.accessField.frame), self.view.frame.size.width - 3*DBButtonMargin - DBButtonWidth, 0) selections:nil selectBlock:^(NSInteger index, NSString *selectedId) {
            weakSelf.accessField.text = selectedId;
            NSArray *tids = [weakSelf.ATDic objectForKey:selectedId];
            [weakSelf.dropList1 setSelections:tids];
            [weakSelf.dropList dismissWithButton:weakSelf.dropBtn];
        }];
        _dropList.layer.borderWidth = 0.5;
        _dropList.backgroundColor = [UIColor whiteColor];
    }
    return _dropList;
}

- (UIButton *)dropBtn{
    if(!_dropBtn){
        _dropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dropBtn setTitle:@"选择" forState:UIControlStateNormal];
        [_dropBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_dropBtn addTarget:self action:@selector(selectAccess) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dropBtn;
}

- (DBDropListView *)dropList1 {
    if(!_dropList1) {
        typeof(self) __weak weakSelf = self;
        _dropList1 = [[DBDropListView alloc] initWithFrame:CGRectMake(CGRectGetMinX(weakSelf.templateField.frame), CGRectGetMaxY(weakSelf.templateField.frame), self.view.frame.size.width - 3*DBButtonMargin - DBButtonWidth, 0) selections:nil selectBlock:^(NSInteger index, NSString *selectedId) {
            weakSelf.templateField.text = selectedId;
            [weakSelf.dropList1 dismissWithButton:weakSelf.dropBtn];
        }];
        _dropList1.layer.borderWidth = 0.5;
        _dropList1.backgroundColor = [UIColor whiteColor];
    }
    return _dropList1;
}

- (UIButton *)dropBtn1{
    if(!_dropBtn1){
        _dropBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dropBtn1 setTitle:@"选择" forState:UIControlStateNormal];
        [_dropBtn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_dropBtn1 addTarget:self action:@selector(selectTemplate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dropBtn1;
}




@end
