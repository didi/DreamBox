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
#import "DBPool.h"

@implementation DBText {
    DBTextModel *_textModel;
}

#pragma mark - DBViewProtocol
-(void)onCreateView{
    [super onCreateView];
    
    _label = [UILabel new];
    [self addSubview:_label];
    self.contentV = _label;
}

-(void)onAttributesBind:(DBViewModel *)attributesModel{
    [super onAttributesBind:attributesModel];
    _textModel = (DBTextModel *)attributesModel;
    if(_textModel.src){
        [self handleChangeOn:_textModel.changeOn];
    }
    
    if(_textModel.maxLines){
        _label.numberOfLines = _textModel.maxLines.integerValue;
    } else {
        _label.numberOfLines = 0;
    }

    if([_textModel.ellipsize isEqual:@"start"]){
        _label.lineBreakMode = NSLineBreakByTruncatingHead;
    } else if([_textModel.ellipsize isEqual:@"middle"]) {
        _label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    } else if([_textModel.ellipsize isEqual:@"end"]){
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
    } else {
        _label.lineBreakMode = NSLineBreakByCharWrapping;
    }
    
    CGFloat textFontSize = 13;
    if ([DBDefines db_getUnit:_textModel.size]) {
        textFontSize = [DBDefines db_getUnit:_textModel.size];
    }
    if ([_textModel.style isEqualToString:@"bold"]) {
        if (@available(iOS 8.2, *)) {
            _label.font = [UIFont systemFontOfSize:textFontSize weight:UIFontWeightBold];
        } else {
            _label.font = [UIFont systemFontOfSize:textFontSize];
        }
    }else{
        _label.font = [UIFont systemFontOfSize:textFontSize];
    }

    if ([_textModel.gravity isEqualToString:@"left"]) {
        _label.textAlignment = NSTextAlignmentLeft;
    }else if([_textModel.gravity isEqualToString:@"right"]){
        _label.textAlignment = NSTextAlignmentRight;
    }else if([_textModel.gravity isEqualToString:@"center"]){
        _label.textAlignment = NSTextAlignmentCenter;
    }
    if (_textModel.color) {
        _label.textColor = [UIColor db_colorWithHexString:_textModel.color];
    }

    [_label setContentHuggingPriority:UILayoutPriorityRequired
                                  forAxis:UILayoutConstraintAxisHorizontal];
    
    [_label setContentHuggingPriority:UILayoutPriorityRequired
                                      forAxis:UILayoutConstraintAxisVertical];

    [self refreshText];
}

- (CGSize)wrapSize {
    if(!_textModel.height ||  [_textModel.height isEqualToString:@"wrap"]){
        CGFloat width = [DBDefines db_getUnit:_textModel.width];
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
    NSString *src = [DBParser getRealValueByPathId:self.pathId andKey:_textModel.src];
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
