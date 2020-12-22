//
//  DBLayout.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/22.
//

#import "DBFlexBoxLayout.h"
#import "DBDefines.h"

@implementation DBFlexBoxLayout

+ (void)flexLayoutView:(UIView *)view withModel:(DBYogaModel *)model{
    [view configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        if(model.flexDirection.length > 0){
            layout.flexDirection = [DBFlexBoxLayout flexDirectionWithKey:model.flexDirection];
        }
        if(model.justifyContent.length > 0){
            layout.justifyContent = [DBFlexBoxLayout justifyWithKey:model.justifyContent];
        }
        if(model.alignContent.length > 0){
            layout.alignContent = [DBFlexBoxLayout alignWithKey:model.alignContent];
        }
        if(model.alignItems.length > 0){
            layout.alignItems = [DBFlexBoxLayout alignWithKey:model.alignItems];
        }
        if(model.alignSelf.length > 0){
            layout.alignSelf = [DBFlexBoxLayout alignWithKey:model.alignSelf];
        }
        if(model.position.length > 0){
            layout.position = [DBFlexBoxLayout positionTypeWithKey:model.position];
        }
        if(model.flexWrap.length > 0){
            layout.flexWrap = [DBFlexBoxLayout wrapWithKey:model.flexWrap];
        }
        if(model.overflow.length > 0){
            layout.overflow = [DBFlexBoxLayout overflowWithKey:model.overflow];
        }
        if(model.display.length > 0){
            layout.display = [DBFlexBoxLayout displayWithKey:model.display];
        }
        if(model.flexGrow.length > 0){
            layout.flexGrow = [DBDefines db_getUnit:model.flexGrow];
        }
        if(model.flexShrink.length > 0){
            layout.flexShrink = [DBDefines db_getUnit:model.flexShrink];
        }
        
        if(model.flexBasis.length > 0){
            if([model.flexBasis containsString:@"%"]){
                layout.flexBasis = YGPercentValue([DBDefines db_getUnit:model.flexBasis]);
            } else {
                layout.flexBasis = YGPointValue([DBDefines db_getUnit:model.flexBasis]);
            }
        }
        
        if(model.left.length > 0){
            layout.left = YGPointValue([DBDefines db_getUnit:model.left]);
        }
        if(model.top.length > 0){
            layout.top = YGPointValue([DBDefines db_getUnit:model.top]);
        }
        if(model.right.length > 0){
            layout.right = YGPointValue([DBDefines db_getUnit:model.right]);
        }
        if(model.bottom.length > 0){
            layout.bottom = YGPointValue([DBDefines db_getUnit:model.bottom]);
        }
        if(model.start.length > 0){
            layout.start = YGPointValue([DBDefines db_getUnit:model.start]);
        }
        if(model.end.length > 0){
            layout.end = YGPointValue([DBDefines db_getUnit:model.end]);
        }
        if(model.marginLeft.length > 0){
            layout.marginLeft = YGPointValue([DBDefines db_getUnit:model.marginLeft]);
        }
        if(model.marginTop.length > 0){
            layout.marginTop = YGPointValue([DBDefines db_getUnit:model.marginTop]);
        }
        if(model.marginRight.length > 0){
            layout.marginRight = YGPointValue([DBDefines db_getUnit:model.marginRight]);
        }
        if(model.marginBottom.length > 0){
            layout.marginBottom = YGPointValue([DBDefines db_getUnit:model.marginBottom]);
        }
        if(model.marginStart.length > 0){
            layout.marginStart = YGPointValue([DBDefines db_getUnit:model.marginStart]);
        }
        if(model.marginEnd.length > 0){
            layout.marginEnd = YGPointValue([DBDefines db_getUnit:model.marginEnd]);
        }
        if(model.marginHorizontal.length > 0){
            layout.marginHorizontal = YGPointValue([DBDefines db_getUnit:model.marginHorizontal]);
        }
        if(model.marginVertical.length > 0){
            layout.marginVertical = YGPointValue([DBDefines db_getUnit:model.marginVertical]);
        }
        if(model.margin.length > 0){
            layout.margin = YGPointValue([DBDefines db_getUnit:model.margin]);
        }
        if(model.paddingLeft.length > 0){
            layout.paddingLeft = YGPointValue([DBDefines db_getUnit:model.paddingLeft]);
        }
        if(model.paddingTop.length > 0){
            layout.paddingTop = YGPointValue([DBDefines db_getUnit:model.paddingTop]);
        }
        if(model.paddingRight.length > 0){
            layout.paddingRight = YGPointValue([DBDefines db_getUnit:model.paddingRight]);
        }
        if(model.paddingBottom.length > 0){
            layout.paddingBottom = YGPointValue([DBDefines db_getUnit:model.paddingBottom]);
        }
        if(model.paddingStart.length > 0){
            layout.paddingStart = YGPointValue([DBDefines db_getUnit:model.paddingStart]);
        }
        if(model.paddingEnd.length > 0){
            layout.paddingEnd = YGPointValue([DBDefines db_getUnit:model.paddingEnd]);
        }
        if(model.paddingHorizontal.length > 0){
            layout.paddingHorizontal = YGPointValue([DBDefines db_getUnit:model.paddingHorizontal]);
        }
        if(model.paddingVertical.length > 0){
            layout.paddingVertical = YGPointValue([DBDefines db_getUnit:model.paddingVertical]);
        }
        if(model.padding.length > 0){
            layout.padding = YGPointValue([DBDefines db_getUnit:model.padding]);
        }
        if(model.width.length > 0){
            CGFloat w = [DBDefines db_getUnit:model.width];
            if(w < 0){
                w = [UIScreen mainScreen].bounds.size.width;
            }
            layout.width = YGPointValue(w);
        }
        if(model.height.length > 0){
            CGFloat h = [DBDefines db_getUnit:model.height];
            if(h < 0){
                h = [UIScreen mainScreen].bounds.size.height;
            }
            layout.height = YGPointValue(h);
        }
        if(model.minWidth.length > 0){
            layout.minWidth = YGPointValue([DBDefines db_getUnit:model.minWidth]);
        }
        if(model.minHeight.length > 0){
            layout.minHeight = YGPointValue([DBDefines db_getUnit:model.minHeight]);
        }
        if(model.maxWidth.length > 0){
            layout.maxWidth = YGPointValue([DBDefines db_getUnit:model.maxWidth]);
        }
        if(model.maxHeight.length > 0){
            layout.maxHeight = YGPointValue([DBDefines db_getUnit:model.maxHeight]);
        }
    }];
}

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
    if([key isEqual:@"space-evenly"]){
        return YGJustifySpaceEvenly;
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
