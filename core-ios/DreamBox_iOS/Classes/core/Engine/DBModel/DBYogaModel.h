//
//  DBYogaModel.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/18.
//

@interface DBYogaModel : NSObject

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

+ (DBYogaModel *)modelWithDict:(NSDictionary *)dict;

@end


@interface DBYogaRenderModel : DBYogaModel

@property (nonatomic, copy) NSString *backgroundColor;
@property (nonatomic, copy) NSString *layout;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSArray *children;

+ (DBYogaRenderModel *)modelWithDict:(NSDictionary *)dict;

@end

