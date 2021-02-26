//
//  DBBaseView.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/8/6.
//

#import "DBXViewProtocol.h"
#import "DBXViewModel.h"
#import <Masonry/Masonry.h>

@class DBXBaseView;

@protocol DBXBaseViewDelegate <NSObject>

@optional

- (void)handleClickView:(DBXBaseView *)baseView actionParam:(NSDictionary *)actionParam;
@end

@interface DBXBaseView : UIView <DBXViewProtocol>

@property (nonatomic, strong) UIView *contentV;
@property (nonatomic, copy) NSString *pathId;
@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic ,copy) NSString *indentifier;//string
@property (nonatomic ,copy) NSString *modelID;//string

@property (nonatomic, strong) NSArray *callBacks;


@property (nonatomic ,strong) NSDictionary *onClick;//string
@property (nonatomic ,strong) NSDictionary *onVisible;
@property (nonatomic ,strong) NSDictionary *onInvisible;
@property (nonatomic ,weak) id<DBXBaseViewDelegate> baseViewDelegate;

@property (nonatomic, strong) DBXViewModel *model;


- (void)handleChangeOn:(NSString *)changeOnstr;
@end

