//
//  DBActions.h
//  DreamBox_iOS
//
//  Created by didi on 2020/7/16.
//

#import <Foundation/Foundation.h>
#import "DBXActionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBXActions : NSObject <DBXActionProtocol>

@end

@interface DBXLogAction : DBXActions

@end

@interface DBXNetAction : DBXActions

@end

@interface DBXTraceAction : DBXActions

@end

@interface DBXNavAction : DBXActions

@end

@interface DBXStorageAction : DBXActions


@end

@interface DBXDialogAction : DBXActions

@end

@interface DBXToastAction : DBXActions

@end

@interface DBXChangeMetaAction : DBXActions

@end

@interface DBXInvokeAction : DBXActions

@end

@interface DBXClosePageAction : DBXActions

@end

@interface DBXSendEventAction : DBXActions

@end

@interface DBXOnEventAction : DBXActions

@end


NS_ASSUME_NONNULL_END
