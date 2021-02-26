//
//  DBLoading.h
//  DreamBox_iOS
//
//  Created by didi on 2020/7/5.
//

#import "DBXView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXLoading : DBXView <DBXViewProtocol>

-(void)setDataWithModel:(DBXLoadingModel *)loadingModel andPathId:(NSString *)pathId;

@end

NS_ASSUME_NONNULL_END
