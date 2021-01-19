//
//  DBCallBack.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/11/9.
//

#import "DBCallBack.h"
#import "NSDictionary+DBExtends.h"
#import "DBParser.h"
#import "UIView+DBStrike.h"
#import "DBTreeView.h"

@implementation DBCallBack

+ (void)bindView:(UIView *)view withCallBacks:(NSArray *)callBacks pathId:(NSString *)pathId{
    __weak typeof(view) weakView = view;
    
    for(NSDictionary *callBack in [callBacks mutableCopy]){
        NSString *type = [callBack db_objectForKey:@"_type"];
        if([type isEqual:@"onClick"]){
            [view db_addTapGestureActionWithBlock:^(UITapGestureRecognizer * _Nonnull tapAction) {
                UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
                CGRect rect=[view convertRect:view.bounds toView:window];
                NSMutableDictionary *callBacksM = [NSMutableDictionary dictionaryWithDictionary:callBack];
                [callBacksM db_setValue:[NSValue valueWithCGRect:rect] forKey:@"frame"];
                [DBParser circulationActionDict:callBacksM andPathId:pathId];
            }];
        } else if([type isEqual:@"onVisible"]){
            [view setViewVisible:^{
                [DBParser circulationActionDict:callBack andPathId:pathId];
            }];
        } else if([type isEqual:@"OnInVisible"]){
            [view setViewInVisible:^{
                [DBParser circulationActionDict:callBack andPathId:pathId];
            }];
        } else if([type isEqual:@"onPositive"]){
            //绑定在弹窗组件上TODO
        } else if([type isEqual:@"onNegative"]){
            //绑定在弹窗组件上TODO
        } else if([type isEqual:@"onEvent"]){
            if([view isKindOfClass:[DBTreeView class]]){
                [(DBTreeView *)view regiterOnEvent:callBack];
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
