//
//  DBModel.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBViewModel : NSObject
@property (nonatomic ,copy) NSString *type;//string
@property (nonatomic ,copy) NSString *modelID;//string

//相对布局&弹性布局 公用属性
@property (nonatomic, copy) NSString *marginLeft;           //外边距
@property (nonatomic, copy) NSString *marginTop;
@property (nonatomic, copy) NSString *marginRight;
@property (nonatomic, copy) NSString *marginBottom;
@property (nonatomic, copy) NSString *marginStart;
@property (nonatomic, copy) NSString *marginEnd;
@property (nonatomic, copy) NSString *marginHorizontal;
@property (nonatomic, copy) NSString *marginVertical;
@property (nonatomic, copy) NSString *margin;

@property (nonatomic, copy) NSString *paddingLeft;          //内边距
@property (nonatomic, copy) NSString *paddingTop;
@property (nonatomic, copy) NSString *paddingRight;
@property (nonatomic, copy) NSString *paddingBottom;
@property (nonatomic, copy) NSString *paddingStart;
@property (nonatomic, copy) NSString *paddingEnd;
@property (nonatomic, copy) NSString *paddingHorizontal;
@property (nonatomic, copy) NSString *paddingVertical;
@property (nonatomic, copy) NSString *padding;

@property (nonatomic, copy) NSString *width;                //宽/高/最大最小限制
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *minWidth;
@property (nonatomic, copy) NSString *minHeight;
@property (nonatomic, copy) NSString *maxWidth;
@property (nonatomic, copy) NSString *maxHeight;

//相对约束属性 V3.0
@property (nonatomic ,copy) NSString *leftToLeft;//id
@property (nonatomic ,copy) NSString *leftToRight;//id
@property (nonatomic ,copy) NSString *rightToRight;//id
@property (nonatomic ,copy) NSString *rightToLeft;//id
@property (nonatomic ,copy) NSString *topToTop;//id
@property (nonatomic ,copy) NSString *topToBottom;//id
@property (nonatomic ,copy) NSString *bottomToTop;//id
@property (nonatomic ,copy) NSString *bottomToBottom;//id

//弹性约束属性 V4.0（flex box）
@property (nonatomic, copy) NSString *isEnabled;
@property (nonatomic, copy) NSString *flexDirection;        //主轴方向
@property (nonatomic, copy) NSString *justifyContent;       //主轴对齐方式
@property (nonatomic, copy) NSString *alignContent;         //侧轴整体对齐方式
@property (nonatomic, copy) NSString *alignItems;           //侧轴单行对齐方式
@property (nonatomic, copy) NSString *alignSelf;            //单个item侧轴对齐方式
@property (nonatomic, copy) NSString *position;             //布局解析类型（绝对/相对）
@property (nonatomic, copy) NSString *flexWrap;             //轴线上排列不下时，换行方式
@property (nonatomic, copy) NSString *overflow;             //内容溢出展示方式（裁剪/溢出/滚动）
@property (nonatomic, copy) NSString *display;              //item是否参与布局计算
@property (nonatomic, copy) NSString *flexGrow;             //延展系数
@property (nonatomic, copy) NSString *flexShrink;           //收缩系数
@property (nonatomic, copy) NSString *flexBasis;            //弹性伸缩初始值
@property (nonatomic, copy) NSString *left;                 //相对偏移/绝对位置
@property (nonatomic, copy) NSString *top;
@property (nonatomic, copy) NSString *right;
@property (nonatomic, copy) NSString *bottom;
@property (nonatomic, copy) NSString *start;
@property (nonatomic, copy) NSString *end;

//其他属性
@property (nonatomic ,copy) NSString *backgroundUrl;//url
@property (nonatomic ,copy) NSString *backgroundColor;//#000000
@property (nonatomic ,copy) NSString *visibleOn;//默认visible，只能接bool，如指定则只能等到true再展示
@property (nonatomic ,copy) NSString *changeOn; //指对哪些数据敏感，当相关数据发生变化时，当前DreamBox视图整体会刷新，属性内容为数据的key，可通过|连接多个数值
@property (nonatomic ,copy) NSString *shape;
@property (nonatomic ,copy) NSString *radius;
@property (nonatomic ,copy) NSString *borderWidth;
@property (nonatomic ,copy) NSString *borderColor;
@property (nonatomic ,copy) NSString *gradientColor;
@property (nonatomic ,copy) NSString *gradientOrientation;
@property (nonatomic ,copy) NSString *scroll;
@property (nonatomic ,copy) NSString *userInteractionEnabled;
@property (nonatomic ,copy) NSString *radiusLT;
@property (nonatomic ,copy) NSString *radiusRT;
@property (nonatomic ,copy) NSString *radiusLB;
@property (nonatomic ,copy) NSString *radiusRB;
//回调节点
@property (nonatomic, strong) NSArray *callbacks;
//触发节点
@property (nonatomic ,strong) NSDictionary *onClick;
@property (nonatomic ,strong) NSDictionary *onVisible;
@property (nonatomic ,strong) NSDictionary *onInvisible;
//子节点
@property (nonatomic,strong) NSArray *children;
+ (DBViewModel *)modelWithDict:(NSDictionary *)dict;
@end

@interface DBTreeModel : DBViewModel

@property (nonatomic,strong) NSMutableDictionary *meta;
@property (nonatomic,strong) NSArray *render;
@property (nonatomic,assign) BOOL dismissOn;
@property (nonatomic,copy) NSString *displayType;
@property (nonatomic,strong) NSDictionary *actionAlias;
@property (nonatomic,strong) NSDictionary *onEvent;
@property (nonatomic,copy) NSString *isSubTree;

@end


@interface DBTextModel : DBViewModel

@property (nonatomic,copy) NSString *src;
@property (nonatomic,copy) NSString *size;
@property (nonatomic,copy) NSString *color;
@property (nonatomic,copy) NSString *style;
@property (nonatomic,copy) NSString *gravity;
@property (nonatomic,copy) NSString *maxLines;
@property (nonatomic,copy) NSString *ellipsize;
@property (nonatomic,copy) NSString *minWidth;
@property (nonatomic,copy) NSString *maxWidth;
@property (nonatomic,copy) NSString *minHeight;
@property (nonatomic,copy) NSString *maxHeight;

@end

@interface DBProgressModel : DBViewModel

@property (nonatomic,copy) NSString *value;
@property (nonatomic,copy) NSString *barBg;
@property (nonatomic,copy) NSString *barFg;
@property (nonatomic,copy) NSString *barBgColor;
@property (nonatomic,copy) NSString *barFgColor;
@property (nonatomic,copy) NSString *patchType;
@property (nonatomic,copy) NSString *radius;
@end


@interface DBListModel : DBViewModel

@property (nonatomic,copy) NSString * src;
@property (nonatomic,copy) NSString * pullRefresh;
@property (nonatomic,copy) NSString *loadMore;
@property (nonatomic,copy) NSString * pageIndex;
@property (nonatomic,copy) NSString * orientation;
@property (nonatomic,copy) NSDictionary *onMore;
@property (nonatomic,copy) NSDictionary *onPull;
@property (nonatomic,copy) NSArray *vh;
@property (nonatomic,copy) NSArray *header;
@property (nonatomic,copy) NSArray *footer;

@end


@interface DBImageModel : DBViewModel

@property (nonatomic,copy) NSString *src;
@property (nonatomic,copy) NSString *scaleType;
@property (nonatomic,copy) NSString *srcType;

@end

@interface DBLoadingModel : DBViewModel

@property (nonatomic, copy) NSString *style;

@end

@interface DBFlowModel : DBViewModel

@property (nonatomic,copy) NSString *src;
@property (nonatomic,copy) NSString *hSpace;
@property (nonatomic,copy) NSString *vSpace;
@property (nonatomic,copy) NSArray *children;

@end


NS_ASSUME_NONNULL_END
