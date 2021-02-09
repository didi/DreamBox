//
//  DBXViewProtocol.h
//  DreamBox_iOS
//
//  Created by didi on 2020/5/28.
//

#import <Foundation/Foundation.h>
#import "DBXViewModel.h"

@class DBXBaseView;

NS_ASSUME_NONNULL_BEGIN

@protocol DBXViewProtocol <NSObject>

-(void)onCreateView;
-(void)onAttributesBind:(DBXViewModel *)attributesModel;
-(void)onChildrenBind:(DBXBaseView *)view model:(DBXViewModel *)model;

@required
@property (nonatomic, strong) DBXViewModel *model;

- (void)reload;

-(void)setDataWithModel:(DBXViewModel *)model andPathId:(NSString *)pathId;

-(CGSize)wrapSize;

@end

NS_ASSUME_NONNULL_END
