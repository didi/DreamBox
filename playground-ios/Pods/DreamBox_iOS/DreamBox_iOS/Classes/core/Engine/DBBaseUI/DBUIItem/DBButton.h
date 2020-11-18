//
//  DBButton.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBView.h"
#import "DBViewModel.h"
#import "DBViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface DBButton : UIButton <DBViewProtocol>

@property (nonatomic ,strong) DBButtonModel *btnModel;

//DBView的唯一标识
@property (nonatomic ,copy) NSString *indentifier;//string
@property (nonatomic ,copy) NSString *modelID;//string
@property (nonatomic ,strong) NSDictionary *onClick;//string
@property (nonatomic ,strong) NSDictionary *onVisible;
@property (nonatomic ,strong) NSDictionary *onInvisible;

-(void)setDataWithModel:(DBButtonModel*)btnModel andPathId:(NSString *)pathId;


@end

NS_ASSUME_NONNULL_END
