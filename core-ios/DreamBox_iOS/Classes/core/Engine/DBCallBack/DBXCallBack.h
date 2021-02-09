//
//  DBCallBack.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/11/9.
//

#import "DBXView.h"


@interface DBXCallBack : NSObject

+ (instancetype)shareInstance;

//绑定由视图触发的事件
//事件分为两种：1、绑定在某个视图上由视图触发(视图中的callBack层) 2、由逻辑触发，比如网络请求的onSuccess
- (void)bindView:(UIView *)view withCallBacks:(NSArray *)callBacks pathId:(NSString *)pathId;

@end

