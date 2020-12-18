//
//  DBTextV2.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/17.
//

#import <UIKit/UIKit.h>
#import "DBViewProtocol.h"


@interface DBTextV2 : UILabel <DBViewProtocol>
@property (nonatomic, strong) DBTextModel *textModel;
@property (nonatomic, copy) NSString *pathId;
@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic ,copy) NSString *indentifier;//string
@property (nonatomic ,copy) NSString *modelID;//string

@property (nonatomic, strong) NSArray *callBacks;

- (void)handleChangeOn:(NSString *)changeOnstr;

- (void)handleDismissOn:(NSString *)dismissOnStr;

- (void)reload;

@end

