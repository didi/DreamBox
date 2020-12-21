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
#import "DBReferenceModel.h"

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
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
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
    CGFloat maxW = [DBDefines db_getUnit:_textModel.maxWidth];
    CGFloat maxH = [DBDefines db_getUnit:_textModel.maxHeight];
    //已知宽，适配高
    DBReferenceModel *referenceLayout = _textModel.referenceLayout;
    if(!referenceLayout.height ||  [referenceLayout.height isEqualToString:@"wrap"]){
        CGFloat width = [DBDefines db_getUnit:referenceLayout.width];
        if(width <= 0){
            if(_textModel.maxWidth){
                width = maxW;
            } else if (_textModel.minWidth){
                [_label sizeToFit];
                return [self fixedSizeWithSize:_label.frame.size];
            } else {
                //缺少测量方法,交给系统，不计算直接返回
                return CGSizeZero;
            }
        }
        CGSize size = [_label sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
        return [self fixedSizeWithSize:size];
    }
    
    //已知高，适配宽
    if(!referenceLayout.width || [referenceLayout.width isEqualToString:@"wrap"]){
        CGFloat height = [DBDefines db_getUnit:referenceLayout.height];
        if(height <= 0){
            if(_textModel.maxHeight){
                height = maxH;
            } else if (_textModel.minHeight){
                [_label sizeToFit];
                return [self fixedSizeWithSize:_label.frame.size];
            } else {
                //缺少测量方法,交给系统，不计算直接返回
                return CGSizeZero;
            }
        }
        CGSize size = [_label sizeThatFits:CGSizeMake(CGFLOAT_MAX, height)];
        return [self fixedSizeWithSize:size];
    }
    
    return CGSizeZero;
}

- (CGSize)fixedSizeWithSize:(CGSize)size{
    CGFloat wrapWidth = size.width;
    CGFloat wrapHeight = size.height;
    
    CGFloat minW = [DBDefines db_getUnit:_textModel.minWidth];
    CGFloat maxW = [DBDefines db_getUnit:_textModel.maxWidth];
    CGFloat minH = [DBDefines db_getUnit:_textModel.minHeight];
    CGFloat maxH = [DBDefines db_getUnit:_textModel.maxHeight];
    
    //宽度约束
    if((minW > 0) && (size.width < minW)){
        wrapWidth = minW;
    }
    if((maxW > 0) && (size.width > maxW)){
        wrapWidth = maxW;
    }
    
    if((minH > 0) && (size.height < minH)){
        wrapHeight = minH;
    }
    
    if((maxH > 0) && (size.height > maxH)){
        wrapHeight = maxH;
    }
    
    return CGSizeMake(wrapWidth, wrapHeight);
}

#pragma mark - inherited
- (void)reload{
    [self refreshText];
    //刷新size
    CGSize size = [self wrapSize];
    if(size.width > 0 && size.height > 0){
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(size);
        }];
    }
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
