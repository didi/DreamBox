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

+ (void)bindView:(DBView *)view withCallBacks:(NSArray *)callBacks {
    __weak typeof(view) weakView = view;
    
    for(NSDictionary *callBack in [callBacks mutableCopy]){
        NSString *type = [callBack db_objectForKey:@"type"];
        if([type isEqual:@"onClick"]){
            [view db_addTapGestureActionWithBlock:^(UITapGestureRecognizer * _Nonnull tapAction) {
                [DBParser circulationActionDict:callBack andPathId:view.pathId];
            }];
        } else if([type isEqual:@"onVisible"]){
            [view setViewVisible:^{
                [DBParser circulationActionDict:callBack andPathId:weakView.pathId];
            }];
        } else if([type isEqual:@"OnInVisible"]){
            [view setViewInVisible:^{
                [DBParser circulationActionDict:callBack andPathId:weakView.pathId];
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
