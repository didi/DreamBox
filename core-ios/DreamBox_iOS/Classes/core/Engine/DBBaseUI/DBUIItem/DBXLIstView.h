//
//  DBlistView.h
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/20.
//

#import "DBXBaseView.h"
#import "DBXViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXlistView : DBXBaseView

@property (nonatomic, weak) id<DBXViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
