//
//  DBContainerViewYoga.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import "DBContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBContainerViewYoga : DBContainerView

+ (DBContainerView *)containerViewWithYogaModel:(DBYogaRenderModel *)yogaModel pathid:(NSString *)pathId;

@end

NS_ASSUME_NONNULL_END
