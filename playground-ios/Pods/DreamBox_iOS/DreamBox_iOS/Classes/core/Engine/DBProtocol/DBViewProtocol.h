//
//  DBViewProtocol.h
//  DreamBox_iOS
//
//  Created by didi on 2020/5/28.
//

#import <Foundation/Foundation.h>
#import "DBModelProtocol.h"
#import "DBViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DBViewProtocol <NSObject>

@required

//-(void)setDataWithModel:(DBViewModel *)model;

-(void)setDataWithModel:(DBViewModel *)model andPathId:(NSString *)pathId;

-(CGSize)wrapSize;

@end

NS_ASSUME_NONNULL_END
