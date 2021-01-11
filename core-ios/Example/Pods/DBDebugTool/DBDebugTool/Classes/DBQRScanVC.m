//
//  DBQRScanVC.m
//  DBWSSDemoi
//
//  Created by zhangchu on 2020/7/2.
//  Copyright © 2020 zhangchu. All rights reserved.
//

#import "DBQRScanVC.h"
#import "DBWssTest.h"
#import <AVFoundation/AVFoundation.h>

#define kScreenWidth  self.view.frame.size.width
#define kScreenHeight self.view.frame.size.height
static const CGFloat kBorderW = 100;
static const CGFloat kMargin = 30;

@interface DBQRScanVC ()
<
AVCaptureMetadataOutputObjectsDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, assign) CGRect scanRect;

@end

@implementation DBQRScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
    UIBarButtonItem *albumItem = [[UIBarButtonItem alloc] initWithTitle:@"从相册选择" style:UIBarButtonItemStyleDone target:self action:@selector(albumBtnClicked)];
    self.navigationItem.rightBarButtonItem = albumItem;
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(closeBtnClicked:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    [self startScanQR];
    [self setupMaskView];
    [self setupCloseBtn];
}



- (void)startScanQR{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized || status == AVAuthorizationStatusRestricted) {
        [self loadScanView];
    }else if (status == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadScanView];
                });
            } else {
                [[[UIAlertView alloc] initWithTitle:@"无权限访问相机" message:@"无权限访问相机" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"无权限访问相机" message:@"无权限访问相机" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)loadScanView {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if(input){
        self.session = [[AVCaptureSession alloc]init];
        [self.session addInput:input];
        
        self.output = [[AVCaptureMetadataOutput alloc]init];
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        [self.session addOutput:self.output];
        if ([self.output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            NSArray *metaDataTypes = @[AVMetadataObjectTypeQRCode];
            self.output.metadataObjectTypes = metaDataTypes;
        }
        
        self.layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.layer.frame = [UIScreen mainScreen].bounds;
        [self.view.layer insertSublayer:self.layer atIndex:0];
        
        [self.session startRunning];
    }
}

- (void)setupMaskView {
    UIView *mask = [[UIView alloc] init];
    mask.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
    mask.layer.borderWidth = kBorderW;
    mask.bounds = CGRectMake(0, 0, kScreenWidth + kBorderW + kMargin, kScreenWidth + kBorderW + kMargin);
    mask.center = CGPointMake(kScreenWidth * 0.5, kScreenHeight * 0.5);
    CGRect frame = mask.frame;
    frame.origin.y = 0;
    mask.frame = frame;
    [self.view addSubview:mask];
    
    UIView *belowMask = [[UIView alloc] initWithFrame:CGRectMake(0, mask.frame.size.height, kScreenWidth, kScreenHeight)];
    belowMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self.view addSubview:belowMask];
}

- (void)setupCloseBtn {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    NSString *closeStr = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? @"关闭" : @"模拟器上相机不可用，点击关闭";
    [closeBtn setTitle:closeStr forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn sizeToFit];
    closeBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height * 3 / 4);
    [self.view addSubview:closeBtn];
}

- (void)closeBtnClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)albumBtnClicked{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if(metadataObjects.count > 0){
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject *metaObj = metadataObjects[0];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    //读取二维码信息
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
    CIImage *image = [[CIImage alloc] initWithImage:img];
    NSArray *features = [detector featuresInImage:image];
    NSString *qrInfoStr = @"";
    for (CIQRCodeFeature *feature in features) {
        qrInfoStr = feature.messageString;
        [[DBWssTest shareInstance] openWSSConnectWithIPStr:qrInfoStr];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)dealloc {
    NSLog(@"QrCodeReader - dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.session stopRunning];
    self.session = nil;
    self.layer = nil;
    self.output = nil;
}

@end
