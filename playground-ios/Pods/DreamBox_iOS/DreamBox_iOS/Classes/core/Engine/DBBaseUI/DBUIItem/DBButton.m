//
//  DBButton.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBButton.h"
#import "UIColor+DBColor.h"
#import "DBParser.h"
#import "DBHelper.h"

@implementation DBButton


-(void)setDataWithModel:(DBButtonModel*)buttonModel andPathId:(NSString *)pathId
{
    // 默认13
    CGFloat textFontSize = 13;
    if ([DBDefines db_getUnit:buttonModel.size]) {
        textFontSize = [DBDefines db_getUnit:buttonModel.size];
    }
    
    if ([buttonModel.style isEqualToString:@"bold"]) {
        if (@available(iOS 8.2, *)) {
            self.titleLabel.font = [UIFont systemFontOfSize:textFontSize weight:UIFontWeightBold];
        } else {
            self.titleLabel.font = [UIFont systemFontOfSize:textFontSize];
        }
    }else{
        self.titleLabel.font = [UIFont systemFontOfSize:textFontSize];
    }
    
    //todo lwm bottom top
    if ([buttonModel.gravity isEqualToString:@"left"]) {
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
    }else if([buttonModel.gravity isEqualToString:@"right"]){
        self.titleLabel.textAlignment = NSTextAlignmentRight;
    }else if([buttonModel.gravity isEqualToString:@"center"]){
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (buttonModel.color) {
         [self setTitleColor:[UIColor db_colorWithHexString:buttonModel.color] forState:UIControlStateNormal];
    }
    
    [self setContentHuggingPriority:UILayoutPriorityRequired
                                  forAxis:UILayoutConstraintAxisHorizontal];
    
    NSString *src = [DBParser getRealValueByPathId:pathId andKey:buttonModel.src];
    if ([DBValidJudge isValidString:src]) {
        [self setTitle: src forState:UIControlStateNormal];
    }
    
}

-(CGSize)wrapSize {
    [self sizeToFit];
    return self.frame.size;
}
@end
