//
//  DBModel.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

@class DBXYogaModel;
@class DBXRenderModel;
@class DBXReferenceModel;
@class DBViewModelYoga;
@class DBXFrameModel;

typedef NS_ENUM(NSInteger, DBTreeModelLayoutType) {
    DBTreeModelLayoutTypeReference, //相对布局
    DBTreeModelLayoutTypeYoga //弹性布局
};


#pragma mark - viewModel
@interface DBXViewModel : NSObject
@property (nonatomic, copy) NSString *_type;//string
@property (nonatomic, copy) NSString *type;//string
@property (nonatomic, copy) NSString *modelID;//string
@property (nonatomic, copy) NSString *backgroundUrl;//url
@property (nonatomic, copy) NSString *backgroundColor;//#000000
@property (nonatomic, copy) NSString *shape;
@property (nonatomic, copy) NSString *borderWidth;
@property (nonatomic, copy) NSString *borderColor;
@property (nonatomic, copy) NSString *gradientColor;
@property (nonatomic, copy) NSString *gradientOrientation;
@property (nonatomic, copy) NSString *scroll;
@property (nonatomic, copy) NSString *userInteractionEnabled;
@property (nonatomic, copy) NSString *radius;
@property (nonatomic, copy) NSString *radiusLT;
@property (nonatomic, copy) NSString *radiusRT;
@property (nonatomic, copy) NSString *radiusLB;
@property (nonatomic, copy) NSString *radiusRB;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *height;

@property (nonatomic, copy) NSString *visibleOn;//默认visible，只能接bool，如指定则只能等到true再展示
@property (nonatomic, copy) NSString *changeOn; //指对哪些数据敏感，当相关数据发生变化时，视图整体会刷新，属性内容为数据的key
@property (nonatomic, strong) NSArray *callbacks; //回调节点
@property (nonatomic, strong) NSArray *children; //子节点
@property (nonatomic, strong) DBXYogaModel *yogaLayout; //布局节点,yoga
@property (nonatomic, strong) DBXFrameModel *frameLayout; //布局节点,frame

+ (DBXViewModel *)modelWithDict:(NSDictionary *)dict;
@end

#pragma mark - treeModel
@class DBXRenderModel;


@interface DBXTreeModel : DBXViewModel

@property (nonatomic, strong) NSMutableDictionary *meta;
@property (nonatomic, strong) NSDictionary *actionAlias;
@property (nonatomic, strong) NSDictionary *onEvent; //作为N to B 的bridge使用

@end

@interface DBXTreeModelYoga : DBXTreeModel

@property (nonatomic,strong) DBXRenderModel *render;
+ (DBXTreeModelYoga *)modelWithDict:(NSDictionary *)dict;

@end


#pragma mark - item view Model
@interface DBXTextModel : DBXViewModel

@property (nonatomic,copy) NSString *src;
@property (nonatomic,copy) NSString *size;
@property (nonatomic,copy) NSString *color;
@property (nonatomic,copy) NSString *style;
@property (nonatomic,copy) NSString *gravity;
@property (nonatomic,copy) NSString *maxLines;
@property (nonatomic,copy) NSString *ellipsize;

@end

@interface DBXProgressModel : DBXViewModel

@property (nonatomic,copy) NSString *value;
@property (nonatomic,copy) NSString *barBg;
@property (nonatomic,copy) NSString *barFg;
@property (nonatomic,copy) NSString *barBgColor;
@property (nonatomic,copy) NSString *barFgColor;
@property (nonatomic,copy) NSString *patchType;
@end


@interface DBXlistModelV2 : DBXViewModel

@property (nonatomic,copy) NSString * src;
@property (nonatomic,copy) NSString * pullRefresh;
@property (nonatomic,copy) NSString *loadMore;
@property (nonatomic,copy) NSString * orientation;
@property (nonatomic,copy) NSDictionary *vh;
@property (nonatomic,copy) NSDictionary *header;
@property (nonatomic,copy) NSDictionary *footer;
@property (nonatomic,copy) NSString *hSpace;
@property (nonatomic,copy) NSString *vSpace;
@property (nonatomic,copy) NSString *edgeStart;
@property (nonatomic,copy) NSString *edgeEnd;

//暂未实现
@property (nonatomic,copy) NSDictionary *onMore;
@property (nonatomic,copy) NSDictionary *onPull;
@property (nonatomic,copy) NSString * pageIndex;

@end


@interface DBXImageModel : DBXViewModel

@property (nonatomic,copy) NSString *src;
@property (nonatomic,copy) NSString *scaleType;
@property (nonatomic,copy) NSString *srcType;

@end

@interface DBXLoadingModel : DBXViewModel

@property (nonatomic, copy) NSString *style;

@end

@interface DBXFlowModel : DBXViewModel

@property (nonatomic,copy) NSString *src;
@property (nonatomic,copy) NSString *hSpace;
@property (nonatomic,copy) NSString *vSpace;

@end


