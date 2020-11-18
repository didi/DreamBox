//
//  DBLoading.h
//  DreamBox_iOS
//
//  Created by didi on 2020/7/5.
//

#import "DBView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBLoading : DBView <DBViewProtocol>

-(void)setDataWithModel:(DBLoadingModel *)loadingModel andPathId:(NSString *)pathId;

@end

NS_ASSUME_NONNULL_END
