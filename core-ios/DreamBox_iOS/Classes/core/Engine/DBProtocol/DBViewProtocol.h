//
//  DBViewProtocol.h
//  DreamBox_iOS
//
//  Created by didi on 2020/5/28.
//

#import <Foundation/Foundation.h>
#import "DBViewModel.h"

@class DBBaseView;

NS_ASSUME_NONNULL_BEGIN

@protocol DBViewProtocol <NSObject>

-(void)onCreateView;
-(void)onAttributesBind:(DBViewModel *)attributesModel;
-(void)onChildrenBind:(DBBaseView *)view model:(DBViewModel *)model;

@required
@property (nonatomic, strong) DBViewModel *model;

- (void)reload;

-(void)setDataWithModel:(DBViewModel *)model andPathId:(NSString *)pathId;

-(CGSize)wrapSize;

@end

NS_ASSUME_NONNULL_END
