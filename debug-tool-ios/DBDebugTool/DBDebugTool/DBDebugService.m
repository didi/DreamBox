//
//  DBDebugService.m
//  DBWSSDemoi
//
//  Created by zhangchu on 2020/7/14.
//  Copyright © 2020 zhangchu. All rights reserved.
//

#import "DBDebugService.h"
#import "DBWssTest.h"
#import "DBDebugViewController.h"

@interface DBDebugService()<DBWSSDelegate>
@property (nonatomic,strong) NSString *currentData;
@property (nonatomic,strong) UIButton *debugButton;
@property (nonatomic,strong) UIWindow *window;
@end

@implementation DBDebugService

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static DBDebugService *_shareInstance;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[DBDebugService alloc] init];
    });

    return _shareInstance;
}

#pragma mark - lifeCycle
- (instancetype)init{
    if(self = [super init]){
        [DBWssTest shareInstance].delegate = self;
    }
    return self;
}

- (void)showDebugbutton
{
    
    self.window=[[UIWindow  alloc] initWithFrame:CGRectMake(0, 200, 60, 60)];
    self.window.windowLevel=1001;
    self.window.backgroundColor=[UIColor grayColor];
    self.window.layer.cornerRadius=20;
    self.window.layer.masksToBounds=YES;
    self.debugButton.userInteractionEnabled = YES;
    
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor clearColor];
    
    self.debugButton =[UIButton  buttonWithType:UIButtonTypeSystem];
    self.debugButton.backgroundColor = [UIColor grayColor];
    self.debugButton.frame=CGRectMake(0, 0, 60, 60);
    [self.debugButton setTitle:@"调试" forState:UIControlStateNormal];
    [self.debugButton  addTarget:self action:@selector(openDebugVC) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:self.debugButton];
    
    [self.window setRootViewController:vc];
    [self.window makeKeyAndVisible];
    self.window.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePostion:)];
    [self.window addGestureRecognizer:pan];
}


- (void)hideDebugbutton{
    [self.window removeFromSuperview];
    self.debugButton = nil;
    self.window = nil;
}

- (void)openDebugVC{
    DBDebugViewController *debugVC = [DBDebugViewController new];
    id vc = [DBDebugService currentNC];
    if([vc isKindOfClass: [UINavigationController class]]) {
        [(UINavigationController *)vc pushViewController:debugVC animated:YES];
    } else if ([vc isKindOfClass: [UIViewController class]]) {
        [(UIViewController *)vc presentViewController:debugVC animated:YES completion:nil];
    }
}

+ (UINavigationController *)currentNC
{
    if (![[UIApplication sharedApplication].windows.lastObject isKindOfClass:[UIWindow class]]) {
        NSAssert(0, @"未获取到导航控制器");
        return nil;
    }
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self getCurrentNCFrom:rootViewController];
}

+ (id)getCurrentNCFrom:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UINavigationController *nc = ((UITabBarController *)vc).selectedViewController;
        return [self getCurrentNCFrom:nc];
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        if (((UINavigationController *)vc).presentedViewController) {
            return [self getCurrentNCFrom:((UINavigationController *)vc).presentedViewController];
        }
        return [self getCurrentNCFrom:((UINavigationController *)vc).topViewController];
    }
    else if ([vc isKindOfClass:[UIViewController class]]) {
        if (vc.presentedViewController) {
            return [self getCurrentNCFrom:vc.presentedViewController];
        }
        else {
            if(vc.navigationController){
                return vc.navigationController;
            } else {
                return vc;
            }
            
        }
    }
    else {
        NSAssert(0, @"未获取到导航控制器");
        return nil;
    }
}

- (void)changePostion:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self.window];
    self.window.transform = CGAffineTransformTranslate(self.window.transform, point.x, point.y);
    [pan setTranslation:CGPointZero inView:self.window];
}

#pragma mark - publicMethods
- (void)refresh{
    [self.dbView reloadTreeView];
}

- (void)bindWithWss:(NSString *)wss{
    [[DBWssTest shareInstance] openWSSConnectWithIPStr:wss];
}

#pragma mark - delegates
- (void)refreshViewWithData:(NSString *)data{
    _currentData = data;
    [self.dbView reloadWithData:data extMeta:nil];
}

- (void)socketBindFailed{
    
}

#pragma mark - privateMethods
- (void)setUpDBViewWithMetaData:(NSString *)data ext:(NSDictionary *)ext {
    if(self.dbView && data.length > 0){
        //刷新，暂无刷新接口，用重建代替
        
        //方案一、DEBUG服务内部刷新[需要再减少渲染视图侵入]
//        self.dbView = [[DBTreeView alloc] initWithData:data extMeta:ext accessKey:@"test"];
//        [self.dbView reloadTreeView];
        
        //方案二、交给渲染视图刷新
        [self.dbView reloadWithData:data extMeta:nil];
    }
}



#pragma mark - test data
//- (NSDictionary *)pareseExt {
//    NSString *mockDataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CTR_EXT" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
//    NSData *data = [mockDataString dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingAllowFragments error:nil];
//    return dict;
//}
//
//- (NSString *)dblStr {
//    return @"fe4dcff2cee77b333c899dfcf95fcd8a000100000000000000000000ewogImRibCI6IHsKICAibWV0YSI6IHt9LAogICJyZW5kZXIiOiBbCiAgIHsKICAgICJzcmMiOiAiJHtleHQuYmdfaW1hZ2V9IiwKICAgICJ3aWR0aCI6ICIwZHAiLAogICAgImhlaWdodCI6ICJkcCIsCiAgICAidHlwZSI6ICJpbWFnZSIsCiAgICAib25DbGljayI6IHsKICAgICAibmF2IjogewogICAgICAic2NoZW1hIjogIiR7ZXh0LnRhcmdldF91cmx9IgogICAgIH0sCiAgICAgInRyYWNlIjogewogICAgICAia2V5IjogImJlYXRfeF95dW5nIiwKICAgICAgImF0dHIiOiBbCiAgICAgICB7CiAgICAgICAgImtleSI6ICJ0eXBlIiwKICAgICAgICAidmFsdWUiOiAiMSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJta19pZCIsCiAgICAgICAgInZhbHVlIjogIiR7ZXh0Lm1rX2lkfSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJjaGFubmVsX2lkIiwKICAgICAgICAidmFsdWUiOiAiJHtleHQubWtfaWR9IgogICAgICAgfQogICAgICBdCiAgICAgfQogICAgfSwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInRvcFRvVG9wIjogIjAiLAogICAgInJpZ2h0VG9SaWdodCI6ICIwIiwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmxlZnRfdGl0bGUubWVzc2FnZX0iLAogICAgIm1hcmdpbkxlZnQiOiAiMTZkcCIsCiAgICAibWFyZ2luVG9wIjogIjMyZHAiLAogICAgInNpemUiOiAiMTZkcCIsCiAgICAiY29sb3IiOiAiIzIxMkUzMyIsCiAgICAic3R5bGUiOiAiYm9sZCIsCiAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICJpZCI6ICIxIiwKICAgICJ0b3BUb1RvcCI6ICIwIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQubGVmdF9jb250ZW50Lm1lc3NhZ2V9IiwKICAgICJtYXJnaW5Ub3AiOiAiNmRwIiwKICAgICJzaXplIjogIjEyZHAiLAogICAgImNvbG9yIjogIiM5NDlGQTUiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAiaWQiOiAiMiIsCiAgICAibGVmdFRvTGVmdCI6ICIxIiwKICAgICJ0b3BUb0JvdHRvbSI6ICIxIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmxlZnRfY29udGVudF9hcnJvd30iLAogICAgIndpZHRoIjogIjRkcCIsCiAgICAiaGVpZ2h0IjogIjhkcCIsCiAgICAibWFyZ2luTGVmdCI6ICI0ZHAiLAogICAgInR5cGUiOiAiaW1hZ2UiLAogICAgImxlZnRUb1JpZ2h0IjogIjIiLAogICAgInRvcFRvVG9wIjogIjIiLAogICAgImJvdHRvbVRvQm90dG9tIjogIjIiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQucmlnaHRfaW1hZ2V9IiwKICAgICJ3aWR0aCI6ICIxMDBkcCIsCiAgICAiaGVpZ2h0IjogIjkwZHAiLAogICAgIm1hcmdpblRvcCI6ICIxMGRwIiwKICAgICJtYXJnaW5SaWdodCI6ICIxMWRwIiwKICAgICJ0eXBlIjogImltYWdlIiwKICAgICJyaWdodFRvUmlnaHQiOiAiMCIsCiAgICAidG9wVG9Ub3AiOiAiMCIKICAgfSwKICAgewogICAgImJhY2tncm91bmRDb2xvciI6ICIke2V4dC5hY3Rpb25fYXJlYS5iZ19jb2xvcn0iLAogICAgIndpZHRoIjogIjBkcCIsCiAgICAiaGVpZ2h0IjogIjQ0ZHAiLAogICAgInR5cGUiOiAidmlldyIsCiAgICAib25DbGljayI6IHsKICAgICAibmF2IjogewogICAgICAic2NoZW1hIjogIiR7ZXh0LmFjdGlvbl9hcmVhLnRhcmdldF91cmx9IgogICAgIH0sCiAgICAgInRyYWNlIjogewogICAgICAia2V5IjogImJlYXRfeF95dW5nIiwKICAgICAgImF0dHIiOiBbCiAgICAgICB7CiAgICAgICAgImtleSI6ICJ0eXBlIiwKICAgICAgICAidmFsdWUiOiAiMSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJta19pZCIsCiAgICAgICAgInZhbHVlIjogIiR7ZXh0Lm1rX2lkfSIKICAgICAgIH0sCiAgICAgICB7CiAgICAgICAgImtleSI6ICJjaGFubmVsX2lkIiwKICAgICAgICAidmFsdWUiOiAiJHtleHQubWtfaWR9IgogICAgICAgfQogICAgICBdCiAgICAgfQogICAgfSwKICAgICJib3R0b21Ub0JvdHRvbSI6ICIwIiwKICAgICJsZWZ0VG9MZWZ0IjogIjAiLAogICAgInJpZ2h0VG9MZWZ0IjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQuYWN0aW9uX2FyZWEuYXJyb3d9IiwKICAgICJtYXJnaW5SaWdodCI6ICIyM2RwIiwKICAgICJtYXJnaW5Cb3R0b20iOiAiMTdkcCIsCiAgICAid2lkdGgiOiAiMTVkcCIsCiAgICAiaGVpZ2h0IjogIjlkcCIsCiAgICAidHlwZSI6ICJpbWFnZSIsCiAgICAiaWQiOiAiMyIsCiAgICAicmlnaHRUb1JpZ2h0IjogIjAiLAogICAgImJvdHRvbVRvQm90dG9tIjogIjAiCiAgIH0sCiAgIHsKICAgICJzcmMiOiAiJHtleHQuYWN0aW9uX2FyZWEuYnRuX3RleHR9IiwKICAgICJtYXJnaW5Cb3R0b20iOiAiMTRkcCIsCiAgICAibWFyZ2luUmlnaHQiOiAiNGRwIiwKICAgICJjb2xvciI6ICIjMjEyRTMzIiwKICAgICJzaXplIjogIjE0ZHAiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAicmlnaHRUb0xlZnQiOiAiMyIsCiAgICAiYm90dG9tVG9Cb3R0b20iOiAiMCIKICAgfSwKICAgewogICAgInNyYyI6ICIke2V4dC5hY3Rpb25fYXJlYS5kZXNjLm1lc3NhZ2V9IiwKICAgICJjb2xvciI6ICIjMjEyRTMzIiwKICAgICJzaXplIjogIjEyZHAiLAogICAgIm1hcmdpbkxlZnQiOiAiMTZkcCIsCiAgICAibWFyZ2luQm90dG9tIjogIjE0ZHAiLAogICAgInR5cGUiOiAidGV4dCIsCiAgICAiYm90dG9tVG9Cb3R0b20iOiAiMCIsCiAgICAibGVmdFRvTGVmdCI6ICIwIgogICB9LAogICB7CiAgICAic3JjIjogIiR7ZXh0LmNvcm5lcl9pbmNvX2JnfSIsCiAgICAibWFyZ2luQm90dG9tIjogIjJkcCIsCiAgICAidHlwZSI6ICJpbWFnZSIsCiAgICAibGVmdFRvTGVmdCI6ICIxIiwKICAgICJib3R0b21Ub1RvcCI6ICIxIgogICB9CiAgXQogfQp9";
//}
@end
