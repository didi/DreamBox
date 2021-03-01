//
//  DBBaseView.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/8/6.
//

#import "DBXBaseView.h"
#import "DBXParser.h"
#import "DBXPool.h"
#import "NSArray+DBXExtends.h"
#import "UIView+DBXStrike.h"
#import <objc/runtime.h>
#import "DBXDefines.h"
#import "UIColor+DBXColor.h"

@interface DBXBaseView()

@property (nonatomic, strong) NSMutableArray *kvoArrM;

@end

@implementation DBXBaseView

- (void)dealloc{
    if(self.kvoArrM.count > 0){
        NSDictionary *metaDict = [DBXParser getMetaDictByPathId:_pathId];
        [self.kvoArrM enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [metaDict removeObserver:self forKeyPath:obj];
        }];
        [self.kvoArrM removeAllObjects];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
    }
    return self;
}

- (void)onCreateView{
    
}

- (void)onAttributesBind:(DBXViewModel *)attributesModel {
    self.model = attributesModel;
//    DBXReferenceModel *referenceLayout = attributesModel.referenceLayout;
//    if(self.contentV != nil && [self.contentV isKindOfClass:[UILabel class]]){
//        self.translatesAutoresizingMaskIntoConstraints = NO;
//        CGFloat leftPadding = [DBXDefines db_getUnit:referenceLayout.paddingLeft];
//        CGFloat rightPadding = [DBXDefines db_getUnit:referenceLayout.paddingRight];
//        CGFloat topPadding = [DBXDefines db_getUnit:referenceLayout.paddingTop];
//        CGFloat bottomPadding = [DBXDefines db_getUnit:referenceLayout.paddingBottom];
//
//        [self.contentV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(self).offset(leftPadding);
//            make.right.mas_equalTo(self).offset(-rightPadding);
//            make.top.mas_equalTo(self).offset(topPadding);
//            make.bottom.mas_equalTo(self).offset(-bottomPadding);
//        }];
//    }
//
    if (attributesModel.borderWidth) {
        self.layer.borderWidth = [attributesModel.borderWidth floatValue];
    }
    
    if (attributesModel.borderColor) {
        self.layer.borderColor = [UIColor db_colorWithHexString:attributesModel.borderColor].CGColor;
    }
  
    if ([attributesModel.shape isEqualToString:@"circle"]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.bounds.size.height / 2.0;
    }
    
    if(self.model.radius) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = [self.model.radius floatValue];
    }
    
    CGFloat width = [DBXDefines db_getUnit:self.model.width pathId:self.pathId];
    CGFloat height = [DBXDefines db_getUnit:self.model.height pathId:self.pathId];
    
    if(width > 0 && height > 0){
        self.frame = CGRectMake(0, 0, width, height);
        if(self.model.radiusLT
           || self.model.radiusRT
           || self.model.radiusLB
           || self.model.radiusRB){
            
            [DBXDefines makeCornerWithView:self
                                 cornerLT:[DBXDefines db_getUnit:self.model.radiusLT pathId:self.pathId]
                                 cornerRT:[DBXDefines db_getUnit:self.model.radiusRT pathId:self.pathId]
                                 cornerLB:[DBXDefines db_getUnit:self.model.radiusLB pathId:self.pathId]
                                 cornerRB:[DBXDefines db_getUnit:self.model.radiusRB pathId:self.pathId]
             ];
        }
    }
}


- (void)setDataWithModel:(DBXViewModel *)model andPathId:(NSString *)pathId{
    self.model = model;
    _pathId = pathId;
    _accessKey = [[DBXPool shareDBPool] getAccessKeyWithPathId:pathId];
}


- (void)handleChangeOn:(NSString *)changeOnstr
{
    NSDictionary *metaDict = [DBXParser getMetaDictByPathId:_pathId];
    if (!changeOnstr) {
        return;
    }
    [metaDict addObserver:self forKeyPath:changeOnstr options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.kvoArrM db_addObject:changeOnstr];
}

- (void)reload {
    //兜底
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:self.model.changeOn]){
        [self reload];
    }
}

- (NSMutableArray *)kvoArrM{
    if(!_kvoArrM){
        _kvoArrM = [NSMutableArray new];
    }
    return _kvoArrM;
}

//展示时触发block中存储的事件
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (self.viewVisible){
        self.viewVisible();
    }
}

//从父view移除时候调用
- (void)removeFromSuperview{
    [super removeFromSuperview];
    if (self.viewInVisible){
        self.viewInVisible();
    }
}

- (DBXViewModel *)model{
    return _model;
}

@end
