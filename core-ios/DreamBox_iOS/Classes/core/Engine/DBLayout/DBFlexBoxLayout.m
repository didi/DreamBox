//
//  DBLayout.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/22.
//

#import "DBFlexBoxLayout.h"

@implementation DBFlexBoxLayout

//已验证：row，row-reverse，column，flex-start,column-reverse
+ (YGFlexDirection)flexDirectionWithKey:(NSString *)key{
    if([key isEqual:@"row"]){
        return YGFlexDirectionRow;
    }
    if([key isEqual:@"row-reverse"]){
        return YGFlexDirectionRowReverse;
    }
    if([key isEqual:@"column"]){
        return YGFlexDirectionColumn;
    }
    if([key isEqual:@"column-reverse"]){
        return YGFlexDirectionColumnReverse;
    }
    return YGFlexDirectionRow;
}

//已验证：center，space-between，space-around，flex-start,flex-end
+ (YGJustify)justifyWithKey:(NSString *)key{
    if([key isEqual:@"flex-start"]){
        return YGJustifyFlexStart;
    }
    if([key isEqual:@"flex-end"]){
        return YGJustifyFlexEnd;
    }
    if([key isEqual:@"center"]){
        return YGJustifyCenter;
    }
    if([key isEqual:@"space-between"]){
        return YGJustifySpaceBetween;
    }
    if([key isEqual:@"space-around"]){
        return YGJustifySpaceAround;
    }
    return YGJustifyFlexStart;
}
//align-items 验证了 flex-start，flex-end，center
//align-self 验证了 flex-start，flex-end，center,stretch
//align-content 验证了 flex-start，flex-end，center
+ (YGAlign)alignWithKey:(NSString *)key{
    if([key isEqual:@"flex-start"]){
        return YGAlignFlexStart;
    }
    if([key isEqual:@"flex-end"]){
        return YGAlignFlexEnd;
    }
    if([key isEqual:@"center"]){
        return YGAlignCenter;
    }
    if([key isEqual:@"space-between"]){
        return YGAlignSpaceBetween;
    }
    if([key isEqual:@"space-around"]){
        return YGAlignSpaceAround;
    }
    if([key isEqual:@"stretch"]){
        return YGAlignStretch;
    }
    if([key isEqual:@"baseline"]){
        return YGAlignBaseline;
    }
    return YGAlignFlexStart;
}

//已验证relative：参与弹性布局，基于弹性布局位置偏移
//absolute：不参与弹性布局，绝对位置偏移
+ (YGPositionType)positionTypeWithKey:(NSString *)key {
    if([key isEqual:@"relative"]){
        return YGPositionTypeRelative;
    }
    if([key isEqual:@"absolute"]){
        return YGPositionTypeAbsolute;
    }
    return YGPositionTypeRelative;
}

//已验证nowrap，wrap，wrap-reverse
+ (YGWrap)wrapWithKey:(NSString *)key {
    if([key isEqual:@"nowrap"]){
        return YGWrapNoWrap;
    }
    if([key isEqual:@"wrap"]){
        return YGWrapWrap;
    }
    if([key isEqual:@"wrap-reverse"]){
        return YGWrapWrapReverse;
    }
    return YGWrapNoWrap;
}

//验证失败
+ (YGOverflow)overflowWithKey:(NSString *)key {
    if([key isEqual:@"visible"]){
        return YGOverflowVisible;
    }
    if([key isEqual:@"hidden"]){
        return YGOverflowHidden;
    }
    if([key isEqual:@"scroll"]){
        return YGOverflowScroll;
    }
    return YGOverflowVisible;
}

//已验证none，flex
+ (YGDisplay)displayWithKey:(NSString *)key {
    if([key isEqual:@"flex"]){
        return YGDisplayFlex;
    }
    if([key isEqual:@"none"]){
        return YGDisplayNone;
    }
    return YGDisplayFlex;
}
@end
