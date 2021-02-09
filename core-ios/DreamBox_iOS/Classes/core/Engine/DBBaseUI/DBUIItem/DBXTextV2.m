//
//  DBTextV2.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/17.
//

#import "DBXTextV2.h"
#import "DBXViewModel.h"
#import "UIColor+DBXColor.h"
#import "DBXParser.h"
#import "DBXHelper.h"
#import "Masonry.h"
#import "DBXPool.h"
#import "UIView+DBXStrike.h"
#import "DBXValidJudge.h"
#import "NSArray+DBXExtends.h"

@interface DBXTextV2()
@property (nonatomic, strong) NSMutableArray *kvoArrM;
@end

@implementation DBXTextV2

-(void)onCreateView{
}

-(void)onAttributesBind:(DBXViewModel *)attributesModel{
    self.textModel = (DBXTextModel *)attributesModel;
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
    
    if ([self.textModel.gravity isEqualToString:@"left"]) {
        self.textAlignment = NSTextAlignmentLeft;
    }else if([self.textModel.gravity isEqualToString:@"right"]){
        self.textAlignment = NSTextAlignmentRight;
    }else if([self.textModel.gravity isEqualToString:@"center"]){
        self.textAlignment = NSTextAlignmentCenter;
    }
    if (self.textModel.color) {
        NSString *color = [DBXParser getRealValueByPathId:self.pathId andKey:self.textModel.color];
        self.textColor = [UIColor db_colorWithHexString:color];
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
    NSString *src = [DBXParser getRealValueByPathId:self.pathId andKey:self.textModel.src];
    if ([DBXValidJudge isValidString:src]) {
        self.text = [self p_replaceLine:src];
    } else if ([DBXValidJudge isValidDictionary:src]){
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
    
    CGFloat textFontSize = 13;
    if ([DBXDefines db_getUnit:self.textModel.size pathId:self.pathId]) {
        textFontSize = [DBXDefines db_getUnit:self.textModel.size pathId:self.pathId];
    }
    
    if ([self.textModel.style isEqualToString:@"bold"]) {
        if (@available(iOS 8.2, *)) {
            self.font = [UIFont systemFontOfSize:textFontSize weight:UIFontWeightBold];
        } else {
            self.font = [UIFont boldSystemFontOfSize:textFontSize];
        }
    }else if ([self.textModel.style isEqualToString:@"italic"]){
        self.font = [UIFont italicSystemFontOfSize:textFontSize];
    } else if([self.textModel.style isEqualToString:@"strike"]){
        if([DBXValidJudge isValidString:self.text]){
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:self.text];
            [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(0, self.text.length)];
            [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, self.text.length)];
                [self setAttributedText:attri];
        }
        self.font = [UIFont systemFontOfSize:textFontSize];
    } else if([self.textModel.style isEqualToString:@"underline"]) {
        if([DBXValidJudge isValidString:self.text]){
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:self.text];
            [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(0, self.text.length)];
            [attri addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, self.text.length)];
                [self setAttributedText:attri];
        }
        self.font = [UIFont systemFontOfSize:textFontSize];
    } else {
        self.font = [UIFont systemFontOfSize:textFontSize];
    }
    
}

- (NSString *)p_replaceLine:(NSString *)str {
    
    if ([DBXValidJudge isValidString:str]) {
        return [str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];;
    } else {
        return nil;
    }
}

- (void)dealloc{
    if(self.kvoArrM.count > 0){
        NSDictionary *metaDict = [DBXParser getMetaDictByPathId:_pathId];
        [self.kvoArrM enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [metaDict removeObserver:self forKeyPath:obj];
        }];
        [self.kvoArrM removeAllObjects];
    }
}

- (void)handleChangeOn:(NSString *)changeOnstr
{
    NSDictionary *metaDict = [DBXParser getMetaDictByPathId:_pathId];
    if (!changeOnstr) {
        return;
    }
    [metaDict addObserver:self forKeyPath:changeOnstr options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.kvoArrM db_addObject:changeOnstr];
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
