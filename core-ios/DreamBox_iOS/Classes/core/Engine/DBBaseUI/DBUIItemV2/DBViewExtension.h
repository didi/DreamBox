//
//  DBViewExtension.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/17.
//

#import <Foundation/Foundation.h>
#import "DBViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DBViewExtension : NSObject

@property (nonatomic, strong) DBViewModel *model;
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

- (void)handleChangeOn:(NSString *)changeOnstr;

- (void)handleDismissOn:(NSString *)dismissOnStr;

- (void)reload;

@end

NS_ASSUME_NONNULL_END
