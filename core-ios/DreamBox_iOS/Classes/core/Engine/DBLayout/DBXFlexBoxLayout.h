//
//  DBLayout.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/22.
//

#import "UIView+Yoga.h"
#import "DBXYogaModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXFlexBoxLayout : NSObject
//进行view布局属性赋值
+ (void)flexLayoutView:(UIView *)view withModel:(DBXYogaModel *)model pathId:(NSString *)pathId;
//将view从布局中移除
+ (void)removeViewFromFlex:(UIView *)view;
//将view追加到布局
+ (void)addViewIntoFlex:(UIView *)view;


//映射轴线
+ (YGFlexDirection)flexDirectionWithKey:(NSString *)key;

//映射主轴对齐方式
+ (YGJustify)justifyWithKey:(NSString *)key;

//映射侧轴对齐方式
+ (YGAlign)alignWithKey:(NSString *)key;

//映射布局位置类型（绝对/相对）
+ (YGPositionType)positionTypeWithKey:(NSString *)key;

//映射换行方式
+ (YGWrap)wrapWithKey:(NSString *)key;

//映射内容溢出元素框展示方式
+ (YGOverflow)overflowWithKey:(NSString *)key;

//映射是否计入flex布局引擎
+ (YGDisplay)displayWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
