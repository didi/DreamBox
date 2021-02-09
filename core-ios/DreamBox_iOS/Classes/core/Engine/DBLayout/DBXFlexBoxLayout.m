//
//  DBLayout.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/22.
//

#import "DBXFlexBoxLayout.h"
#import "DBXDefines.h"

@implementation DBXFlexBoxLayout

+ (void)flexLayoutView:(UIView *)view withModel:(DBXYogaModel *)model pathId:(NSString *)pathId{
    [view configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        if(model.flexDirection.length > 0){
            layout.flexDirection = [DBXFlexBoxLayout flexDirectionWithKey:model.flexDirection];
        }
        if(model.justifyContent.length > 0){
            layout.justifyContent = [DBXFlexBoxLayout justifyWithKey:model.justifyContent];
        }
        if(model.alignContent.length > 0){
            layout.alignContent = [DBXFlexBoxLayout alignWithKey:model.alignContent];
        }
        if(model.alignItems.length > 0){
            layout.alignItems = [DBXFlexBoxLayout alignWithKey:model.alignItems];
        }
        if(model.alignSelf.length > 0){
            layout.alignSelf = [DBXFlexBoxLayout alignWithKey:model.alignSelf];
        }
        if(model.positionType.length > 0){
            layout.position = [DBXFlexBoxLayout positionTypeWithKey:model.positionType];
        }
        if(model.flexWrap.length > 0){
            layout.flexWrap = [DBXFlexBoxLayout wrapWithKey:model.flexWrap];
        }
        if(model.overflow.length > 0){
            layout.overflow = [DBXFlexBoxLayout overflowWithKey:model.overflow];
        }
        if(model.display.length > 0){
            layout.display = [DBXFlexBoxLayout displayWithKey:model.display];
        }
        if(model.flexGrow.length > 0){
            layout.flexGrow = [DBXDefines db_getUnit:model.flexGrow pathId:pathId];
        }
        if(model.flexShrink.length > 0){
            layout.flexShrink = [DBXDefines db_getUnit:model.flexShrink pathId:pathId];
        }
        
        if(model.flexBasis.length > 0){
            if([model.flexBasis containsString:@"%"]){
                layout.flexBasis = YGPercentValue([DBXDefines db_getUnit:model.flexBasis pathId:pathId]);
            } else {
                layout.flexBasis = YGPointValue([DBXDefines db_getUnit:model.flexBasis pathId:pathId]);
            }
        }
        
        if(model.positionLeft.length > 0){
            if([model.positionLeft containsString:@"%"]){
                layout.left = YGPercentValue([DBXDefines db_getUnit:model.positionLeft pathId:pathId]);
            } else {
                layout.left = YGPointValue([DBXDefines db_getUnit:model.positionLeft pathId:pathId]);
            }
        }
        
        if(model.positionTop.length > 0){
            if([model.positionTop containsString:@"%"]){
                layout.top = YGPercentValue([DBXDefines db_getUnit:model.positionTop pathId:pathId]);
            } else {
                layout.top = YGPointValue([DBXDefines db_getUnit:model.positionTop pathId:pathId]);
            }
        }
        
        if(model.positionRight.length > 0){
            if([model.positionRight containsString:@"%"]){
                layout.right = YGPercentValue([DBXDefines db_getUnit:model.positionRight pathId:pathId]);
            } else {
                layout.right = YGPointValue([DBXDefines db_getUnit:model.positionRight pathId:pathId]);
            }
        }
        
        if(model.positionBottom.length > 0){
            if([model.positionBottom containsString:@"%"]){
                layout.bottom = YGPercentValue([DBXDefines db_getUnit:model.positionBottom pathId:pathId]);
            } else {
                layout.bottom = YGPointValue([DBXDefines db_getUnit:model.positionBottom pathId:pathId]);
            }
        }
        
        if(model.aspectRatio.length > 0){
            layout.aspectRatio = [DBXDefines db_getUnit:model.aspectRatio pathId:pathId];;
        }
        if(model.start.length > 0){
            layout.start = YGPointValue([DBXDefines db_getUnit:model.start pathId:pathId]);
        }
        if(model.end.length > 0){
            layout.end = YGPointValue([DBXDefines db_getUnit:model.end pathId:pathId]);
        }
        if(model.marginLeft.length > 0){
            layout.marginLeft = YGPointValue([DBXDefines db_getUnit:model.marginLeft pathId:pathId]);
        }
        if(model.marginTop.length > 0){
            layout.marginTop = YGPointValue([DBXDefines db_getUnit:model.marginTop pathId:pathId]);
        }
        if(model.marginRight.length > 0){
            layout.marginRight = YGPointValue([DBXDefines db_getUnit:model.marginRight pathId:pathId]);
        }
        if(model.marginBottom.length > 0){
            layout.marginBottom = YGPointValue([DBXDefines db_getUnit:model.marginBottom pathId:pathId]);
        }
        if(model.marginStart.length > 0){
            layout.marginStart = YGPointValue([DBXDefines db_getUnit:model.marginStart pathId:pathId]);
        }
        if(model.marginEnd.length > 0){
            layout.marginEnd = YGPointValue([DBXDefines db_getUnit:model.marginEnd pathId:pathId]);
        }
        if(model.marginHorizontal.length > 0){
            layout.marginHorizontal = YGPointValue([DBXDefines db_getUnit:model.marginHorizontal pathId:pathId]);
        }
        if(model.marginVertical.length > 0){
            layout.marginVertical = YGPointValue([DBXDefines db_getUnit:model.marginVertical pathId:pathId]);
        }
        if(model.margin.length > 0){
            layout.margin = YGPointValue([DBXDefines db_getUnit:model.margin pathId:pathId]);
        }
        if(model.paddingLeft.length > 0){
            layout.paddingLeft = YGPointValue([DBXDefines db_getUnit:model.paddingLeft pathId:pathId]);
        }
        if(model.paddingTop.length > 0){
            layout.paddingTop = YGPointValue([DBXDefines db_getUnit:model.paddingTop pathId:pathId]);
        }
        if(model.paddingRight.length > 0){
            layout.paddingRight = YGPointValue([DBXDefines db_getUnit:model.paddingRight pathId:pathId]);
        }
        if(model.paddingBottom.length > 0){
            layout.paddingBottom = YGPointValue([DBXDefines db_getUnit:model.paddingBottom pathId:pathId]);
        }
        if(model.paddingStart.length > 0){
            layout.paddingStart = YGPointValue([DBXDefines db_getUnit:model.paddingStart pathId:pathId]);
        }
        if(model.paddingEnd.length > 0){
            layout.paddingEnd = YGPointValue([DBXDefines db_getUnit:model.paddingEnd pathId:pathId]);
        }
        if(model.paddingHorizontal.length > 0){
            layout.paddingHorizontal = YGPointValue([DBXDefines db_getUnit:model.paddingHorizontal pathId:pathId]);
        }
        if(model.paddingVertical.length > 0){
            layout.paddingVertical = YGPointValue([DBXDefines db_getUnit:model.paddingVertical pathId:pathId]);
        }
        if(model.padding.length > 0){
            layout.padding = YGPointValue([DBXDefines db_getUnit:model.padding pathId:pathId]);
        }
        if(model.width.length > 0){
            CGFloat w = [DBXDefines db_getUnit:model.width pathId:pathId];
            if(w > 0){
                if([model.width containsString:@"%"]){
                    layout.width = YGPercentValue([DBXDefines db_getUnit:model.width pathId:pathId]);
                } else {
                    layout.width = YGPointValue([DBXDefines db_getUnit:model.width pathId:pathId]);
                }
            } 
        }
        if(model.height.length > 0){
            CGFloat h = [DBXDefines db_getUnit:model.height pathId:pathId];
            if(h > 0){
                if([model.height containsString:@"%"]){
                    layout.height = YGPercentValue([DBXDefines db_getUnit:model.height pathId:pathId]);
                } else {
                    layout.height = YGPointValue([DBXDefines db_getUnit:model.height pathId:pathId]);
                }
            }
            
        }
        if(model.minWidth.length > 0){
            if([model.minWidth containsString:@"%"]){
                layout.minWidth = YGPercentValue([DBXDefines db_getUnit:model.minWidth pathId:pathId]);
            } else {
                layout.minWidth = YGPointValue([DBXDefines db_getUnit:model.minWidth pathId:pathId]);
            }
        }
        if(model.minHeight.length > 0){
            if([model.minHeight containsString:@"%"]){
                layout.minHeight = YGPercentValue([DBXDefines db_getUnit:model.minHeight pathId:pathId]);
            } else {
                layout.minHeight = YGPointValue([DBXDefines db_getUnit:model.minHeight pathId:pathId]);
            }
        }
        if(model.maxWidth.length > 0){
            if([model.maxWidth containsString:@"%"]){
                layout.maxWidth = YGPercentValue([DBXDefines db_getUnit:model.maxWidth pathId:pathId]);
            } else {
                layout.maxWidth = YGPointValue([DBXDefines db_getUnit:model.maxWidth pathId:pathId]);
            }
        }
        if(model.maxHeight.length > 0){
            if([model.maxHeight containsString:@"%"]){
                layout.maxHeight = YGPercentValue([DBXDefines db_getUnit:model.maxHeight pathId:pathId]);
            } else {
                layout.maxHeight = YGPointValue([DBXDefines db_getUnit:model.maxHeight pathId:pathId]);
            }
        }
    }];
    [view.yoga markDirty];
}

+ (void)removeViewFromFlex:(UIView *)view {
    [view configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.display = YGDisplayNone;
        layout.isIncludedInLayout = NO;
    }];
    view.hidden = YES;
    [view.yoga markDirty];
}

+ (void)addViewIntoFlex:(UIView *)view {
    [view configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.display = YGDisplayFlex;
        layout.isIncludedInLayout = YES;
    }];
    view.hidden = NO;
    [view.yoga markDirty];
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
