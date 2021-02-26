//
//  DBCallBack.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/11/9.
//

#import "DBXCallBack.h"
#import "NSDictionary+DBXExtends.h"
#import "DBXParser.h"
#import "UIView+DBXStrike.h"
#import "DBXTreeView.h"

@implementation DBXCallBack

+ (void)bindView:(UIView *)view withCallBacks:(NSArray *)callBacks pathId:(NSString *)pathId{
    for(NSDictionary *callBack in callBacks){
        NSString *type = [callBack db_objectForKey:@"_type"];
        if([type isEqual:@"onClick"]){
            __weak typeof(view) weakView = view;
            [view db_addTapGestureActionWithBlock:^(UITapGestureRecognizer * _Nonnull tapAction) {
                UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
                CGRect rect=[weakView convertRect:weakView.bounds toView:window];
                NSMutableDictionary *callBacksM = [NSMutableDictionary dictionaryWithDictionary:callBack];
                [callBacksM db_setValue:[NSValue valueWithCGRect:rect] forKey:@"frame"];
                NSString *pathID = nil;
                if([weakView respondsToSelector:@selector(pathTid)]){
                    pathID = [weakView performSelector:@selector(pathTid)];
                } else if([weakView respondsToSelector:@selector(pathId)]) {
                    pathID = [weakView performSelector:@selector(pathId)];
                }
                [DBXParser circulationActionDict:callBacksM andPathId:pathID];
            }];
        } else if([type isEqual:@"onVisible"]){
            [view setViewVisible:^{
                [DBXParser circulationActionDict:callBack andPathId:pathId];
            }];
        } else if([type isEqual:@"OnInVisible"]){
            [view setViewInVisible:^{
                [DBXParser circulationActionDict:callBack andPathId:pathId];
            }];
        } else if([type isEqual:@"onPositive"]){
            //绑定在弹窗组件上TODO
        } else if([type isEqual:@"onNegative"]){
            //绑定在弹窗组件上TODO
        } else if([type isEqual:@"onEvent"]){
            if([view isKindOfClass:[DBXTreeView class]]){
                [(DBXTreeView *)view regiterOnEvent:callBack];
            }
        }
//        else if([type isEqual:@"onSuccess"]){
//
//        } else if([type isEqual:@"onError"]){
//
//        }
    }
}

@end
