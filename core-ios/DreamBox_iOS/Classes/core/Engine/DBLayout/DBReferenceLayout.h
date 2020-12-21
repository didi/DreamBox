//
//  DBReferenceLayout.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/21.
//

#import <Foundation/Foundation.h>
#import "DBRecyclePool.h"
#import "DBViewModel.h"
#import "DBView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBReferenceLayout : NSObject

//nslayout
+ (void)layoutAllViews:(DBViewModel *)model andView:(DBView *)view andRelativeViewPool:(DBRecyclePool *)pool;

@end

NS_ASSUME_NONNULL_END
