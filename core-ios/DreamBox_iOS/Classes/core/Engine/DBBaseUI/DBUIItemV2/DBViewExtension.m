//
//  DBViewExtension.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/17.
//

#import "DBViewExtension.h"
#import "DBBaseView.h"
#import "DBParser.h"
#import "DBPool.h"
#import "NSArray+DBExtends.h"
#import "UIView+DBStrike.h"
#import <objc/runtime.h>
#import "DBDefines.h"

@interface DBViewExtension()

@property (nonatomic, strong) NSMutableArray *kvoArrM;

@end

@implementation DBViewExtension

- (void)handleChangeOn:(NSString *)changeOnstr
{
    NSDictionary *metaDict = [DBParser getMetaDictByPathId:_pathId];
    if (!changeOnstr) {
        return;
    }
    [metaDict addObserver:self forKeyPath:changeOnstr options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.kvoArrM addObject:changeOnstr];
}

- (void)handleDismissOn:(NSString *)dismissOnStr
{
    NSDictionary *metaDict = [DBParser getMetaDictByPathId:_pathId];
    if (!dismissOnStr) {
        return;
    }
    [metaDict addObserver:self forKeyPath:dismissOnStr options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.kvoArrM addObject:dismissOnStr];
}

- (void)reload {
    //兜底
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:_model.changeOn]){
        [self reload];
    }
}

- (NSMutableArray *)kvoArrM{
    if(!_kvoArrM){
        _kvoArrM = [NSMutableArray new];
    }
    return _kvoArrM;
}

@end
