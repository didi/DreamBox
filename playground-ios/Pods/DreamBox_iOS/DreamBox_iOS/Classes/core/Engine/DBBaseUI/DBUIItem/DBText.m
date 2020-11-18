//
//  DBText.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBText.h"
#import "DBViewModel.h"
#import "UIColor+DBColor.h"
#import "DBParser.h"
#import "DBHelper.h"
#import "Masonry.h"

@implementation DBText {
    UILabel *_label;
}

#pragma mark - lideCycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _label = [UILabel new];
        [self addSubview:_label];
        
    }
    return self;
}

#pragma mark - DBViewProtocol
-(void)setDataWithModel:(DBTextModel *)textModel andPathId:(NSString *)pathId{
    [super setDataWithModel:textModel andPathId:pathId];
    
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.mas_equalTo(self);
    }];
    
    if(textModel.src){
        [self handleChangeOn:textModel.changeOn];
    }
    
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByCharWrapping;
    
    CGFloat textFontSize = 13;
    if ([DBDefines db_getUnit:textModel.size]) {
        textFontSize = [DBDefines db_getUnit:textModel.size];
    }
    if ([textModel.style isEqualToString:@"bold"]) {
        if (@available(iOS 8.2, *)) {
            _label.font = [UIFont systemFontOfSize:textFontSize weight:UIFontWeightBold];
        } else {
            _label.font = [UIFont systemFontOfSize:textFontSize];
        }
    }else{
        _label.font = [UIFont systemFontOfSize:textFontSize];
    }

    if ([textModel.gravity isEqualToString:@"left"]) {
        _label.textAlignment = NSTextAlignmentLeft;
    }else if([textModel.gravity isEqualToString:@"right"]){
        _label.textAlignment = NSTextAlignmentRight;
    }else if([textModel.gravity isEqualToString:@"center"]){
        _label.textAlignment = NSTextAlignmentCenter;
    }
    if (textModel.color) {
        _label.textColor = [UIColor db_colorWithHexString:textModel.color];
    }

    [_label setContentHuggingPriority:UILayoutPriorityRequired
                                  forAxis:UILayoutConstraintAxisHorizontal];
    
    [_label setContentHuggingPriority:UILayoutPriorityRequired
                                      forAxis:UILayoutConstraintAxisVertical];

    [self refreshText];
}

- (CGSize)wrapSize {
    if(!self.model.height ||  [self.model.height isEqualToString:@"wrap"]){
        CGFloat width = [DBDefines db_getUnit:self.model.width];
        if(width <= 0){width = [UIScreen mainScreen].bounds.size.width;} //缺少测量方法，伪造宽度为屏幕宽
        CGSize size = [_label sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
        return size;
    } else {
        CGSize size = [_label sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        return size;
    }
}

#pragma mark - inherited
- (void)reload{
    [self refreshText];
    //刷新size
    CGSize size = [self wrapSize];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];
}

#pragma mark - privateMethods
- (void)refreshText{
    DBTextModel *textModel = (DBTextModel *)self.model;
    NSString *src = [DBParser getRealValueByPathId:self.pathId andKey:textModel.src];
    if ([DBValidJudge isValidString:src]) {
        _label.text = [self p_replaceLine:src];
    } else if ([DBValidJudge isValidDictionary:src]){
        NSDictionary *dic = (NSDictionary *)src;
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dic options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        NSLog(@"%@",myString);
        if (!err) {
            _label.text = myString;
        }
    }
    
    if([src isKindOfClass:[NSNumber class]]){
        NSNumber *num = (NSNumber *)src;
        _label.text = num.stringValue;
    }
}

- (NSString *)p_replaceLine:(NSString *)str {
    
    if ([DBValidJudge isValidString:str]) {
        return [str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];;
    } else {
        return nil;
    }
}
@end
