//
//  DBViewController.m
//  DreamBox_iOS
//
//  Created by fangshaosheng on 05/26/2020.
//  Copyright (c) 2020 fangshaosheng. All rights reserved.
//

#import "DBViewController2.h"

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

@interface DBViewController2 ()

@property (nonatomic,strong) DBTreeView *dbView;

@property (nonatomic, strong) DBTreeView *DBResView;

@property (nonatomic, strong) DBTreeView *DBDiffView;

@end

@implementation DBViewController2

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
//    [[DBFactory sharedInstance] registModelClass:[DBMyViewModel class] byType:@"myView"];
//    [[DBFactory sharedInstance] registModelClass:[DBMyViewModel class] byType:@"myView1"];
//    [[DBFactory sharedInstance] registModelClass:[DBMyViewModel class] byType:@"lauoutTestView"];
//
//    [[DBFactory sharedInstance] registViewClass:[DBMyView class] byType:@"myView"];
//    [[DBFactory sharedInstance] registViewClass:[DBMyView1 class] byType:@"myView1"];
//    [[DBFactory sharedInstance] registViewClass:[DBMyTestView class] byType:@"lauoutTestView"];
//
//
//    [[DBFactory sharedInstance] registActionClass:[DBMyAction class] byType:@"myAction"];
    
//    [super viewDidLoad];
    //catalog接口
//    [[DBDebugService shareInstance] showDebugbutton];
    // Do any additional setup after loading the view, typically from a nib.

//    [self createDBView];
//    [self createDBResView];
//    [self createDBDiffView];

//    [[DBService shareDBService] putAccessKey:@"DEMO" itemKey:@"key" itemValue:@"这是我"];

    
//    [[DBService shareDBService] registerAccessKey:@"123" wrapper:nil];
//
    
//    [self creatDBbyTid:@"test"];

    [self wrapperTest];
}

- (void)creatDBbyTid:(NSString *)tid {
//    NSDictionary *ext = [self pareseExt];
    
    NSDictionary *ext = @{
        @"head_image":@"https://static.didialift.com/pinche/gift/resource/j6o0iv9d12-1593851925321-%E6%8F%92%E5%9B%BE%403x.png",
        @"head_title":@"请打开双闪，正对车辆拍摄",
        @"first_line":@"•  请停靠至安全地带，打开双闪并拍摄车辆",
        @"second_line":@"•  距离车辆正前方1-2米完成拍摄",
        @"flash_image":@"https://static.didialift.com/pinche/gift/resource/7tsruqgi4h-1593854827460-%E5%8F%8C%E9%97%AA%403x.png",
        @"flash_text":@"打开双闪",
        @"light_image":@"https://static.didialift.com/pinche/gift/resource/p9bi7hev7bo-1593854827460-%E5%85%89%E7%BA%BF%403x.png",
        @"light_text":@"光线充足",
        @"car_image":@"https://static.didialift.com/pinche/gift/resource/80jsn0d9e48-1593854827459-%E8%BD%A6%403x.png",
        @"car_text":@"正对车辆",
        @"photo_button":@"开始拍摄",
        @"button_bg_url":@"https://static.didialift.com/pinche/gift/resource/e604ulc481g-1593918061546-home_3_back%403x.png",
        @"target_url":@"https://www.baidu.com"
    };
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
      
      [dict setValue:@{@"message":@"行程已发布\n邀请前需完成车主安全任务"} forKey:@"title"];
      [dict setValue:@"去完成安全任务" forKey:@"btn_text"];
      [dict setValue:@"https://custom.starrydigital.cn\/didi\/index_carpool.html?mk_version=5.4.2&mk_cityid=1&mk_os=2&mk_uid=1205022035968&cid=13652&mkch=501284" forKey:@"scheme"];
      [dict setValue:@"" forKey:@"pending_task"];
      
      NSMutableDictionary *secDic = [NSMutableDictionary dictionary];
      [secDic setValue:@"https://static.didialift.com/pinche/gift/resource/02mp5o2etjc-1597125740629-safe_task_img.jpg" forKey:@"icon"];
      [secDic setValue:@{@"message":@"安全功能确认"} forKey:@"title"];
      [secDic setValue:@{@"message":@"安全功能确认提高出行安全性"} forKey:@"sub_title"];
      
      [dict setValue:@[secDic.mutableCopy,secDic.mutableCopy,secDic.mutableCopy] forKey:@"contents"];
    
    self.dbView = [[DBTreeView alloc] init];
    [self.dbView loadWithTemplateId:tid accessKey:@"DEMO" extData:dict completionBlock:^(BOOL successed, NSError * _Nullable error) {
        
    }];
    
//    [self.dbView resetExtensionMetaData:ext];
    
//    CGFloat w = 351;
////    CGFloat height = [self.dbView getTreeViewHeight];
//    CGFloat h = 155;
//    self.dbView.frame = CGRectMake((self.view.frame.size.width - w)/2, 300,w , h);
    self.dbView.frame = self.view.bounds;
//    self.dbView.backgroundColor = UIColor.grayColor;
    [self.view addSubview:self.dbView];
    
    
//    [self.dbView registerEventWithEventID:@"closePage" andBlock:^(NSString * _Nonnull evendID, NSDictionary * _Nonnull paramDict, NSDictionary * _Nonnull callbackData) {
//
//        NSLog(@"123");
//    }];
//
}



- (void)createDBView {
    NSDictionary *ext = [self pareseExt];
    CGFloat w = 351;
    CGFloat h = 155;
    
    self.dbView = [[DBTreeView alloc] initWithData:[self dbl_reverseStr] extMeta:ext accessKey:@"DEMO" tid:nil];
    self.dbView.frame = CGRectMake(0, 0 ,self.view.bounds.size.width , self.view.bounds.size.height);
    [self.view addSubview:self.dbView];
}


- (void)createDBResView {
    NSDictionary *ext = [self pareseExt];
    CGFloat w = 351;
    CGFloat h = 155;
    
    self.DBResView = [[DBTreeView alloc] initWithData:[self dblStr] extMeta:ext accessKey:@"DEMO" tid:nil];
    self.DBResView.frame = CGRectMake((self.view.frame.size.width - w)/2, 200,w , h);
    [self.view addSubview:self.DBResView];
    
}
- (void)createDBDiffView {
    
    NSDictionary *ext = [self pareseExt];
    CGFloat w = 351;
    CGFloat h = 155;
    
    self.DBDiffView = [[DBTreeView alloc] initWithData:[self dbDiffStr] extMeta:ext accessKey:@"DEMO" tid:nil];
    self.DBDiffView.frame = CGRectMake((self.view.frame.size.width - w)/2, 400,w , h);
    [self.view addSubview:self.DBDiffView];
}




- (NSString *)dblStr {
    return @"7b13eae423c0c7f6019593bcdadc05de000100000000000000000000ewogImRibCI6IHsKICAibWV0YSI6IHsKICAgImhlYWRfaW1hZ2UiOiAiaHR0cHM6Ly9zdGF0aWMuZGlkaWFsaWZ0LmNvbS9waW5jaGUvZ2lmdC9yZXNvdXJjZS80ZjVvcHVxcjRkby0xNTk0MDI5NzU3ODA3LWNhckRldGVjdC5naWYiLAogICAiZmxhc2hfaW1hZ2UiOiAiaHR0cHM6Ly9zdGF0aWMuZGlkaWFsaWZ0LmNvbS9waW5jaGUvZ2lmdC9yZXNvdXJjZS83dHNydXFnaTRoLTE1OTM4NTQ4Mjc0NjAtJUU1JThGJThDJUU5JTk3JUFBJTQwM3gucG5nIiwKICAgImxpZ2h0X2ltYWdlIjogImh0dHBzOi8vc3RhdGljLmRpZGlhbGlmdC5jb20vcGluY2hlL2dpZnQvcmVzb3VyY2UvcDliaTdoZXY3Ym8tMTU5Mzg1NDgyNzQ2MC0lRTUlODUlODklRTclQkElQkYlNDAzeC5wbmciLAogICAiY2FyX2ltYWdlIjogImh0dHBzOi8vc3RhdGljLmRpZGlhbGlmdC5jb20vcGluY2hlL2dpZnQvcmVzb3VyY2UvODBqc24wZDllNDgtMTU5Mzg1NDgyNzQ1OS0lRTglQkQlQTYlNDAzeC5wbmciLAogICAiYnV0dG9uX2JnX3VybCI6ICJodHRwczovL3N0YXRpYy5kaWRpYWxpZnQuY29tL3BpbmNoZS9naWZ0L3Jlc291cmNlLzZkOHZtZ2J2ZmFvLTE1OTQwOTUyNDQ2OTgtUmVjdGFuZ2xlQmFjayU0MDN4LnBuZyIKICB9LAogICJyZW5kZXIiOiBbCiAgIHsKICAgICJ3aWR0aCI6ICIyOTVkcCIsCiAgICAiaGVpZ2h0IjogIjE0OGRwIiwKICAgICJzcmMiOiAiJHtoZWFkX2ltYWdlfSIsCiAgICAibWFyZ2luVG9wIjogIjE2ZHAiLAogICAgInNjYWxlVHlwZSI6ICJjcm9wIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJpZCI6ICIxIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInJpZ2h0VG9SaWdodCI6ICIwIiwKICAgICJ0b3BUb1RvcCI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmhlYWRfdGl0bGV9IiwKICAgICJ3aWR0aCI6ICIwZHAiLAogICAgIm1hcmdpblRvcCI6ICIzMmRwIiwKICAgICJtYXJnaW5MZWZ0IjogIjQwZHAiLAogICAgIm1hcmdpblJpZ2h0IjogIjQwZHAiLAogICAgInNpemUiOiAiMjJkcCIsCiAgICAiY29sb3IiOiAiIzIxMkUzMyIsCiAgICAic3R5bGUiOiAiYm9sZCIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJpZCI6ICIyIiwKICAgICJ0b3BUb0JvdHRvbSI6ICIxIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInJpZ2h0VG9SaWdodCI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmZpcnN0X2xpbmV9IiwKICAgICJ3aWR0aCI6ICIwZHAiLAogICAgIm1hcmdpblRvcCI6ICIyMGRwIiwKICAgICJzaXplIjogIjE0ZHAiLAogICAgImNvbG9yIjogIiM0QTU1NUIiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAiaWQiOiAiMyIsCiAgICAibGVmdFRvTGVmdCI6ICIyIiwKICAgICJyaWdodFRvUmlnaHQiOiAiMiIsCiAgICAidG9wVG9Cb3R0b20iOiAiMiIKICAgfSwKICAgewogICAgInNyYyI6ICIke2V4dC5zZWNvbmRfbGluZX0iLAogICAgIndpZHRoIjogIjBkcCIsCiAgICAibWFyZ2luVG9wIjogIjEyZHAiLAogICAgInNpemUiOiAiMTRkcCIsCiAgICAiY29sb3IiOiAiIzRBNTU1QiIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJpZCI6ICI0IiwKICAgICJsZWZ0VG9MZWZ0IjogIjIiLAogICAgInJpZ2h0VG9SaWdodCI6ICIyIiwKICAgICJ0b3BUb0JvdHRvbSI6ICIzIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LnRocmlkX2xpbmV9IiwKICAgICJ3aWR0aCI6ICIwZHAiLAogICAgIm1hcmdpblRvcCI6ICIxMmRwIiwKICAgICJzaXplIjogIjE0ZHAiLAogICAgImNvbG9yIjogIiM0QTU1NUIiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAiaWQiOiAiNSIsCiAgICAibGVmdFRvTGVmdCI6ICIyIiwKICAgICJyaWdodFRvUmlnaHQiOiAiMiIsCiAgICAidG9wVG9Cb3R0b20iOiAiNCIKICAgfSwKICAgewogICAgImJhY2tncm91bmRDb2xvciI6ICIjRUNFREYwIiwKICAgICJ3aWR0aCI6ICIwZHAiLAogICAgImhlaWdodCI6ICIxcHgiLAogICAgIm1hcmdpblRvcCI6ICIzMGRwIiwKICAgICJ0eXBlIjogInZpZXciLAogICAgImlkIjogIjYiLAogICAgImxlZnRUb0xlZnQiOiAiMiIsCiAgICAicmlnaHRUb1JpZ2h0IjogIjIiLAogICAgInRvcFRvQm90dG9tIjogIjUiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtmbGFzaF9pbWFnZX0iLAogICAgIndpZHRoIjogIjQzZHAiLAogICAgImhlaWdodCI6ICI0M2RwIiwKICAgICJtYXJnaW5MZWZ0IjogIjQ4ZHAiLAogICAgIm1hcmdpblRvcCI6ICIzMGRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJpZCI6ICI3IiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInRvcFRvVG9wIjogIjYiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQuZmxhc2hfdGV4dH0iLAogICAgIm1hcmdpblRvcCI6ICI2ZHAiLAogICAgInNpemUiOiAiMTRkcCIsCiAgICAiY29sb3IiOiAiIzk0OUZBNSIsCiAgICAiZ3Jhdml0eSI6ICJjZW50ZXIiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAibGVmdFRvTGVmdCI6ICI3IiwKICAgICJyaWdodFRvUmlnaHQiOiAiNyIsCiAgICAidG9wVG9Cb3R0b20iOiAiNyIKICAgfSwKICAgewogICAgInNyYyI6ICIke2xpZ2h0X2ltYWdlfSIsCiAgICAid2lkdGgiOiAiNDNkcCIsCiAgICAiaGVpZ2h0IjogIjQzZHAiLAogICAgIm1hcmdpblRvcCI6ICIzMGRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInJpZ2h0VG9SaWdodCI6ICIwIiwKICAgICJ0b3BUb1RvcCI6ICI2IgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmxpZ2h0X3RleHR9IiwKICAgICJtYXJnaW5Ub3AiOiAiNmRwIiwKICAgICJzaXplIjogIjE0ZHAiLAogICAgImNvbG9yIjogIiM5NDlGQTUiLAogICAgImdyYXZpdHkiOiAiY2VudGVyIiwKICAgICJ0eXBlIjogInRleHQiLAogICAgImxlZnRUb0xlZnQiOiAiMCIsCiAgICAicmlnaHRUb1JpZ2h0IjogIjAiLAogICAgInRvcFRvQm90dG9tIjogIjgiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtjYXJfaW1hZ2V9IiwKICAgICJ3aWR0aCI6ICI0M2RwIiwKICAgICJoZWlnaHQiOiAiNDNkcCIsCiAgICAibWFyZ2luUmlnaHQiOiAiNDhkcCIsCiAgICAibWFyZ2luVG9wIjogIjMwZHAiLAogICAgInR5cGUiOiAiaW1hZ2UiLAogICAgImlkIjogIjgiLAogICAgInJpZ2h0VG9SaWdodCI6ICIwIiwKICAgICJ0b3BUb1RvcCI6ICI2IgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmNhcl90ZXh0fSIsCiAgICAibWFyZ2luVG9wIjogIjZkcCIsCiAgICAic2l6ZSI6ICIxNGRwIiwKICAgICJjb2xvciI6ICIjOTQ5RkE1IiwKICAgICJncmF2aXR5IjogImNlbnRlciIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJsZWZ0VG9MZWZ0IjogIjgiLAogICAgInJpZ2h0VG9SaWdodCI6ICI4IiwKICAgICJ0b3BUb0JvdHRvbSI6ICI4IgogICB9LAogICB7CiAgICAic3JjIjogIiR7YnV0dG9uX2JnX3VybH0iLAogICAgIm1hcmdpbkxlZnQiOiAiMTZkcCIsCiAgICAibWFyZ2luQm90dG9tIjogIjE2ZHAiLAogICAgIm1hcmdpblJpZ2h0IjogIjE2ZHAiLAogICAgImhlaWdodCI6ICI1MGRwIiwKICAgICJzY2FsZVR5cGUiOiAiZml0WFkiLAogICAgInR5cGUiOiAiaW1hZ2UiLAogICAgIm9uQ2xpY2siOiB7CiAgICAgIm5hdiI6IHsKICAgICAgInNjaGVtYSI6ICIke2V4dC50YXJnZXRfdXJsfSIKICAgICB9CiAgICB9LAogICAgImlkIjogIjkiLAogICAgImxlZnRUb0xlZnQiOiAiMCIsCiAgICAicmlnaHRUb1JpZ2h0IjogIjAiLAogICAgImJvdHRvbVRvQm90dG9tIjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQucGhvdG9fYnV0dG9ufSIsCiAgICAiY29sb3IiOiAiI0ZGRkZGRiIsCiAgICAic2l6ZSI6ICIxOGRwIiwKICAgICJ0eXBlIjogInRleHQiLAogICAgImxlZnRUb0xlZnQiOiAiMCIsCiAgICAicmlnaHRUb1JpZ2h0IjogIjAiLAogICAgImJvdHRvbVRvQm90dG9tIjogIjkiLAogICAgInRvcFRvVG9wIjogIjkiCiAgIH0KICBdCiB9Cn0=";
}


- (NSString *)dbl_reverseStr {
    return @"fc91e19ddb6a03eed1e90d2d42db7dd3000100000000000000000000ewogImRibCI6IHsKICAibWV0YSI6IHsKICAgImhlbGxvX3RleHQiOiAiSGVsbG8gRHJlYW1Cb3ghIiwKICAgInJpZ2h0X2J0bl92aXNpYmxlIjogImZhbHNlIiwKICAgImltZ19zcmMiOiAiaHR0cHM6Ly9pbWFnZXMudW5zcGxhc2guY29tL3Bob3RvLTE1OTM2NDI1MzE5NTUtYjYyZTE3YmRhYTljP2l4bGliPXJiLTEuMi4xJml4aWQ9ZXlKaGNIQmZhV1FpT2pFeU1EZDkmYXV0bz1mb3JtYXQmZml0PWNyb3Amdz0xNjUwJnE9ODAiCiAgfSwKICAicmVuZGVyIjogWwogICB7CiAgICAic3JjIjogIiR7aGVsbG9fdGV4dH0iLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAiaWQiOiAiMSIsCiAgICAibGVmdFRvTGVmdCI6ICIwIiwKICAgICJyaWdodFRvUmlnaHQiOiAiMCIKICAgfSwKICAgewogICAgInNyYyI6ICJUb0JvdHRvbSBvZiBIZWxsbyB0ZXh0IiwKICAgICJtYXJnaW5Ub3AiOiAiMzNkcCIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJpZCI6ICIyIiwKICAgICJ0b3BUb1RvcCI6ICIxIgogICB9LAogICB7CiAgICAic3JjIjogIkNlbnRlciBCdXR0b24iLAogICAgInR5cGUiOiAiYnV0dG9uIiwKICAgICJ0b3BUb0JvdHRvbSI6ICIyIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiQ2VudGVyIFRleHQiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAibGVmdFRvTGVmdCI6ICIwIiwKICAgICJyaWdodFRvUmlnaHQiOiAiMCIsCiAgICAidG9wVG9Ub3AiOiAiMCIsCiAgICAiYm90dG9tVG9Cb3R0b20iOiAiMCIKICAgfSwKICAgewogICAgInNyYyI6ICIke2ltZ19zcmN9IiwKICAgICJ3aWR0aCI6ICIxNTBkcCIsCiAgICAiaGVpZ2h0IjogIjE1MGRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgImJvdHRvbVRvQm90dG9tIjogIjAiCiAgIH0KICBdCiB9Cn0=";
}
- (NSString *)dbDiffStr {
    return  @"cf6f4e1842a0076afbe42d4ba255af56000100000000000000000000ewogImRibCI6IHsKICAibWV0YSI6IHt9LAogICJyZW5kZXIiOiBbCiAgIHsKICAgICJzcmMiOiAiJHtleHQuYmdfaW1hZ2V9IiwKICAgICJ3aWR0aCI6ICIwZHAiLAogICAgImhlaWdodCI6ICJkcCIsCiAgICAidHlwZSI6ICJpbWFnZSIsCiAgICAib25DbGljayI6IHsKICAgICAibmF2IjogewogICAgICAic2NoZW1hIjogIiR7ZXh0LnRhcmdldF91cmx9IgogICAgIH0sCiAgICAgInRyYWNlIjogewogICAgICAia2V5IjogImJlYXRfeF95dW5nIiwKICAgICAgImF0dHIiOiBbCiAgICAgICB7CiAgICAgICAgImtleSI6ICJ0eXBlIiwKICAgICAgICAidmFsdWUiOiAiMSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJta19pZCIsCiAgICAgICAgInZhbHVlIjogIiR7ZXh0Lm1rX2lkfSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJjaGFubmVsX2lkIiwKICAgICAgICAidmFsdWUiOiAiJHtleHQubWtfaWR9IgogICAgICAgfQogICAgICBdCiAgICAgfQogICAgfSwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInRvcFRvVG9wIjogIjAiLAogICAgInJpZ2h0VG9SaWdodCI6ICIwIiwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmxlZnRfdGl0bGUubWVzc2FnZX0iLAogICAgIm1hcmdpbkxlZnQiOiAiMTZkcCIsCiAgICAibWFyZ2luVG9wIjogIjMyZHAiLAogICAgInNpemUiOiAiMTZkcCIsCiAgICAiY29sb3IiOiAiIzIxMkUzMyIsCiAgICAic3R5bGUiOiAiYm9sZCIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJpZCI6ICIxIiwKICAgICJ0b3BUb1RvcCI6ICIwIiwKICAgICJsZWZ0VG9SaWdodCI6ICIzIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmxlZnRfY29udGVudC5tZXNzYWdlfSIsCiAgICAibWFyZ2luVG9wIjogIjZkcCIsCiAgICAic2l6ZSI6ICIxMmRwIiwKICAgICJjb2xvciI6ICIjOTQ5RkE1IiwKICAgICJ0eXBlIjogInRleHQiLAogICAgImlkIjogIjIiLAogICAgImxlZnRUb0xlZnQiOiAiMSIsCiAgICAidG9wVG9Cb3R0b20iOiAiMSIKICAgfSwKICAgewogICAgInNyYyI6ICIke2V4dC5sZWZ0X2NvbnRlbnRfYXJyb3d9IiwKICAgICJ3aWR0aCI6ICI0ZHAiLAogICAgImhlaWdodCI6ICI4ZHAiLAogICAgIm1hcmdpbkxlZnQiOiAiNGRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJsZWZ0VG9SaWdodCI6ICIyIiwKICAgICJ0b3BUb1RvcCI6ICIyIiwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIyIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LnJpZ2h0X2ltYWdlfSIsCiAgICAid2lkdGgiOiAiMTAwZHAiLAogICAgImhlaWdodCI6ICI5MGRwIiwKICAgICJtYXJnaW5Ub3AiOiAiMTBkcCIsCiAgICAibWFyZ2luUmlnaHQiOiAiMTFkcCIsCiAgICAibWFyZ2luTGVmdCI6ICIxNmRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJpZCI6ICIzIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInRvcFRvVG9wIjogIjAiCiAgIH0sCiAgIHsKICAgICJiYWNrZ3JvdW5kQ29sb3IiOiAiJHtleHQuYWN0aW9uX2FyZWEuYmdfY29sb3J9IiwKICAgICJoZWlnaHQiOiAiNDRkcCIsCiAgICAidHlwZSI6ICJ2aWV3IiwKICAgICJvbkNsaWNrIjogewogICAgICJuYXYiOiB7CiAgICAgICJzY2hlbWEiOiAiJHtleHQuYWN0aW9uX2FyZWEudGFyZ2V0X3VybH0iCiAgICAgfSwKICAgICAidHJhY2UiOiB7CiAgICAgICJrZXkiOiAiYmVhdF94X3l1bmciLAogICAgICAiYXR0ciI6IFsKICAgICAgIHsKICAgICAgICAia2V5IjogInR5cGUiLAogICAgICAgICJ2YWx1ZSI6ICIxIgogICAgICAgfSwKICAgICAgIHsKICAgICAgICAia2V5IjogIm1rX2lkIiwKICAgICAgICAidmFsdWUiOiAiJHtleHQubWtfaWR9IgogICAgICAgfSwKICAgICAgIHsKICAgICAgICAia2V5IjogImNoYW5uZWxfaWQiLAogICAgICAgICJ2YWx1ZSI6ICIke2V4dC5ta19pZH0iCiAgICAgICB9CiAgICAgIF0KICAgICB9CiAgICB9LAogICAgImJvdHRvbVRvQm90dG9tIjogIjAiLAogICAgImxlZnRUb0xlZnQiOiAiMCIsCiAgICAicmlnaHRUb0xlZnQiOiAiMCIKICAgfSwKICAgewogICAgInNyYyI6ICIke2V4dC5hY3Rpb25fYXJlYS5hcnJvd30iLAogICAgIm1hcmdpblJpZ2h0IjogIjIzZHAiLAogICAgIm1hcmdpbkJvdHRvbSI6ICIxN2RwIiwKICAgICJ3aWR0aCI6ICIxNWRwIiwKICAgICJoZWlnaHQiOiAiOWRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJpZCI6ICI0IiwKICAgICJyaWdodFRvUmlnaHQiOiAiMCIsCiAgICAiYm90dG9tVG9Cb3R0b20iOiAiMCIKICAgfSwKICAgewogICAgInNyYyI6ICIke2V4dC5hY3Rpb25fYXJlYS5idG5fdGV4dH0iLAogICAgIm1hcmdpbkJvdHRvbSI6ICIxNGRwIiwKICAgICJtYXJnaW5SaWdodCI6ICI0ZHAiLAogICAgImNvbG9yIjogIiMyMTJFMzMiLAogICAgInNpemUiOiAiMTRkcCIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJyaWdodFRvTGVmdCI6ICI0IiwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmFjdGlvbl9hcmVhLmRlc2MubWVzc2FnZX0iLAogICAgImNvbG9yIjogIiMyMTJFMzMiLAogICAgInNpemUiOiAiMTJkcCIsCiAgICAibWFyZ2luTGVmdCI6ICIxNmRwIiwKICAgICJtYXJnaW5Cb3R0b20iOiAiMTRkcCIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQuY29ybmVyX2luY29fYmd9IiwKICAgICJtYXJnaW5Cb3R0b20iOiAiMmRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJsZWZ0VG9MZWZ0IjogIjEiLAogICAgImJvdHRvbVRvVG9wIjogIjEiCiAgIH0KICBdCiB9Cn0=";
    
    return @"f80a9dd40cd93aa2762140cc677a5e6d000100000000000000000000ewogImRibCI6IHsKICAibWV0YSI6IHt9LAogICJyZW5kZXIiOiBbCiAgIHsKICAgICJzcmMiOiAiJHtleHQuYmdfaW1hZ2V9IiwKICAgICJ3aWR0aCI6ICIwZHAiLAogICAgImhlaWdodCI6ICJkcCIsCiAgICAidHlwZSI6ICJpbWFnZSIsCiAgICAib25DbGljayI6IHsKICAgICAibmF2IjogewogICAgICAic2NoZW1hIjogIiR7ZXh0LnRhcmdldF91cmx9IgogICAgIH0sCiAgICAgInRyYWNlIjogewogICAgICAia2V5IjogImJlYXRfeF95dW5nIiwKICAgICAgImF0dHIiOiBbCiAgICAgICB7CiAgICAgICAgImtleSI6ICJ0eXBlIiwKICAgICAgICAidmFsdWUiOiAiMSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJta19pZCIsCiAgICAgICAgInZhbHVlIjogIiR7ZXh0Lm1rX2lkfSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJjaGFubmVsX2lkIiwKICAgICAgICAidmFsdWUiOiAiJHtleHQubWtfaWR9IgogICAgICAgfQogICAgICBdCiAgICAgfQogICAgfSwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInRvcFRvVG9wIjogIjAiLAogICAgInJpZ2h0VG9SaWdodCI6ICIwIiwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmRiZC5yaWdodF9pbWFnZX0iLAogICAgIndpZHRoIjogIjEwMGRwIiwKICAgICJoZWlnaHQiOiAiOTBkcCIsCiAgICAibWFyZ2luVG9wIjogIjEwZHAiLAogICAgIm1hcmdpblJpZ2h0IjogIjEwMGRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJyaWdodFRvUmlnaHQiOiAiMCIsCiAgICAidG9wVG9Ub3AiOiAiMCIKICAgfSwKICAgewogICAgInNyYyI6ICIke2V4dC5kYmQuaWNvbn0iLAogICAgIndpZHRoIjogIjEzNWRwIiwKICAgICJoZWlnaHQiOiAiOTBkcCIsCiAgICAibWFyZ2luTGVmdCI6ICIyMGRwIiwKICAgICJtYXJnaW5Ub3AiOiAiMTVkcCIsCiAgICAidHlwZSI6ICJpbWFnZSIsCiAgICAiaWQiOiAiMSIsCiAgICAibGVmdFRvTGVmdCI6ICIwIiwKICAgICJ0b3BUb1RvcCI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmRiZC50aW1lfSIsCiAgICAibWFyZ2luTGVmdCI6ICI1ZHAiLAogICAgInNpemUiOiAiMTJkcCIsCiAgICAiY29sb3IiOiAiIzIxMkUzMyIsCiAgICAic3R5bGUiOiAiYm9sZCIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJpZCI6ICIyIiwKICAgICJ0b3BUb1RvcCI6ICIxIiwKICAgICJsZWZ0VG9SaWdodCI6ICIxIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmRiZC5sZXZlbH0iLAogICAgIm1hcmdpblRvcCI6ICIxMGRwIiwKICAgICJzaXplIjogIjEyZHAiLAogICAgImNvbG9yIjogIiMyMTJFMzMiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAidG9wVG9Cb3R0b20iOiAiMiIsCiAgICAibGVmdFRvTGVmdCI6ICIyIgogICB9LAogICB7CiAgICAiYmFja2dyb3VuZENvbG9yIjogIiR7ZXh0LmFjdGlvbl9hcmVhLmJnX2NvbG9yfSIsCiAgICAiaGVpZ2h0IjogIjQ0ZHAiLAogICAgInR5cGUiOiAidmlldyIsCiAgICAib25DbGljayI6IHsKICAgICAibmF2IjogewogICAgICAic2NoZW1hIjogIiR7ZXh0LmFjdGlvbl9hcmVhLnRhcmdldF91cmx9IgogICAgIH0sCiAgICAgInRyYWNlIjogewogICAgICAia2V5IjogImJlYXRfeF95dW5nIiwKICAgICAgImF0dHIiOiBbCiAgICAgICB7CiAgICAgICAgImtleSI6ICJ0eXBlIiwKICAgICAgICAidmFsdWUiOiAiMSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJta19pZCIsCiAgICAgICAgInZhbHVlIjogIiR7ZXh0Lm1rX2lkfSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJjaGFubmVsX2lkIiwKICAgICAgICAidmFsdWUiOiAiJHtleHQubWtfaWR9IgogICAgICAgfQogICAgICBdCiAgICAgfQogICAgfSwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInJpZ2h0VG9MZWZ0IjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQuZGJkLmNvbm5lY3R9IiwKICAgICJtYXJnaW5Cb3R0b20iOiAiMTRkcCIsCiAgICAibWFyZ2luUmlnaHQiOiAiNDBkcCIsCiAgICAiY29sb3IiOiAiIzIxMkUzMyIsCiAgICAic2l6ZSI6ICIxNGRwIiwKICAgICJ0eXBlIjogInRleHQiLAogICAgInJpZ2h0VG9SaWdodCI6ICIwIiwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmRiZC5kZXNjfSIsCiAgICAiY29sb3IiOiAiIzIxMkUzMyIsCiAgICAic2l6ZSI6ICIxMmRwIiwKICAgICJtYXJnaW5MZWZ0IjogIjE2ZHAiLAogICAgIm1hcmdpbkJvdHRvbSI6ICIxNGRwIiwKICAgICJ0eXBlIjogInRleHQiLAogICAgImJvdHRvbVRvQm90dG9tIjogIjAiLAogICAgImxlZnRUb0xlZnQiOiAiMCIKICAgfQogIF0KIH0KfQ==";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)wrapperTest {
    NSDate *begin = [NSDate date];
    NSString *mockDataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"drvSafeReport" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    //解析dict
    
    self.dbView = [[DBTreeView alloc] initWithJsonSting:mockDataString extMeta:nil accessKey:@"DEMO" tid:nil];
    
    [self.view addSubview:self.dbView];
    [self.dbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    NSDate *end = [NSDate date];
    NSTimeInterval deltaTime = [end timeIntervalSinceDate:begin];
    NSLog(@"耗时：%fms", deltaTime*1000);
    [self.dbView registerEventWithEventID:@"2001" andBlock:^(NSString * _Nonnull evendID, NSDictionary * _Nonnull paramDict, NSDictionary * _Nonnull callbackData) {
        
        //客户端处理逻辑
        NSString *newEventCbMsg = @"newEventCbMsg";
        
        //将客户端要传递给DB的数据，与callBackData，一起传递给DB
        [self.dbView handleDBCallBack:callbackData data:newEventCbMsg];
    }];
//    [self.dbView sendEventWithEventID:@"1000" data:@"newEventOn"];
}


- (NSDictionary *)pareseExt {
    NSString *mockDataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CTR_EXT" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [mockDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}
@end
