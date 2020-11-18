//
//  DBActions.h
//  DreamBox_iOS
//
//  Created by didi on 2020/7/16.
//

#import <Foundation/Foundation.h>
#import "DBActionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBActions : NSObject <DBActionProtocol>

@end

@interface DBLogAction : DBActions

@end

@interface DBNetAction : DBActions

@end

@interface DBTraceAction : DBActions

@end

@interface DBNavAction : DBActions

@end

@interface DBStorageAction : DBActions


@end

@interface DBDialogAction : DBActions

@end

@interface DBToastAction : DBActions

@end

@interface DBChangeMetaAction : DBActions

@end

@interface DBInvokeAction : DBActions

@end

@interface DBClosePageAction : DBActions

@end

@interface DBSendEventAction : DBActions

@end

@interface DBOnEventAction : DBActions

@end


NS_ASSUME_NONNULL_END
