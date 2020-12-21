//
//  DBTextV2.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/17.
//

#import "DBTextV2.h"
#import "DBViewModel.h"
#import "UIColor+DBColor.h"
#import "DBParser.h"
#import "DBHelper.h"
#import "Masonry.h"
#import "DBPool.h"
#import "UIView+DBStrike.h"

@interface DBTextV2()
@property (nonatomic, strong) NSMutableArray *kvoArrM;
@end

@implementation DBTextV2

-(void)onCreateView{
}

-(void)onAttributesBind:(DBViewModel *)attributesModel{
    self.textModel = (DBTextModel *)attributesModel;
    if(self.textModel.src){
        [self handleChangeOn:self.textModel.changeOn];
    }
    
    if(self.textModel.maxLines){
        self.numberOfLines = self.textModel.maxLines.integerValue;
    } else {
        self.numberOfLines = 0;
    }

    if([self.textModel.ellipsize isEqual:@"start"]){
        self.lineBreakMode = NSLineBreakByTruncatingHead;
    } else if([self.textModel.ellipsize isEqual:@"middle"]) {
        self.lineBreakMode = NSLineBreakByTruncatingMiddle;
    } else if([self.textModel.ellipsize isEqual:@"end"]){
        self.lineBreakMode = NSLineBreakByTruncatingTail;
    } else {
        self.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    CGFloat textFontSize = 13;
    if ([DBDefines db_getUnit:self.textModel.size]) {
        textFontSize = [DBDefines db_getUnit:self.textModel.size];
    }
    if ([self.textModel.style isEqualToString:@"bold"]) {
        if (@available(iOS 8.2, *)) {
            self.font = [UIFont systemFontOfSize:textFontSize weight:UIFontWeightBold];
        } else {
            self.font = [UIFont systemFontOfSize:textFontSize];
        }
    }else{
        self.font = [UIFont systemFontOfSize:textFontSize];
    }

    if ([self.textModel.gravity isEqualToString:@"left"]) {
        self.textAlignment = NSTextAlignmentLeft;
    }else if([self.textModel.gravity isEqualToString:@"right"]){
        self.textAlignment = NSTextAlignmentRight;
    }else if([self.textModel.gravity isEqualToString:@"center"]){
        self.textAlignment = NSTextAlignmentCenter;
    }
    if (self.textModel.color) {
        self.textColor = [UIColor db_colorWithHexString:self.textModel.color];
    }

    [self refreshText];
}

#pragma mark - inherited
- (void)reload{
    [self refreshText];
    //刷新size
}

#pragma mark - privateMethods
- (void)refreshText{
    NSString *src = [DBParser getRealValueByPathId:self.pathId andKey:self.textModel.src];
    if ([DBValidJudge isValidString:src]) {
        self.text = [self p_replaceLine:src];
    } else if ([DBValidJudge isValidDictionary:src]){
        NSDictionary *dic = (NSDictionary *)src;
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dic options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        NSLog(@"%@",myString);
        if (!err) {
            self.text = myString;
        }
    }
    
    if([src isKindOfClass:[NSNumber class]]){
        NSNumber *num = (NSNumber *)src;
        self.text = num.stringValue;
    }
}

- (NSString *)p_replaceLine:(NSString *)str {
    
    if ([DBValidJudge isValidString:str]) {
        return [str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];;
    } else {
        return nil;
    }
}

- (void)dealloc{
    [self handleDismissOn:self.textModel.changeOn];
    if(self.kvoArrM.count > 0){
        NSDictionary *metaDict = [DBParser getMetaDictByPathId:_pathId];
        [self.kvoArrM enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [metaDict removeObserver:self forKeyPath:obj];
        }];
        [self.kvoArrM removeAllObjects];
    }
}

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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:self.textModel.changeOn]){
        [self reload];
    }
}

- (NSMutableArray *)kvoArrM{
    if(!_kvoArrM){
        _kvoArrM = [NSMutableArray new];
    }
    return _kvoArrM;
}

//展示时触发block中存储的事件
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (self.viewVisible){
        self.viewVisible();
    }
}

//从父view移除时候调用
- (void)removeFromSuperview{
    [super removeFromSuperview];
    if (self.viewInVisible){
        self.viewInVisible();
    }
}


@end
