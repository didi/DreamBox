//
//  DBBaseView.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/8/6.
//

#import "DBXViewProtocol.h"
#import "DBXViewModel.h"
#import "Masonry.h"

@interface DBXBaseView : UIView <DBXViewProtocol>

@property (nonatomic, strong) UIView *contentV;
@property (nonatomic, copy) NSString *pathId;
@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic ,copy) NSString *indentifier;//string
@property (nonatomic ,copy) NSString *modelID;//string

@property (nonatomic, strong) NSArray *callBacks;

- (void)handleChangeOn:(NSString *)changeOnstr;
@end

