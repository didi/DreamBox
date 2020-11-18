//
//  DBWrapperConfigModel.h
//  DreamBox_iOS
//
//  Created by fangshaosheng on 2020/6/28.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, DBReportFrequency) {
    DBReportFrequencyONCE,//一个模板一次
    DBReportFrequencySAMPLE,//取样
    DBReportFrequencyEVERY,//每次
};

NS_ASSUME_NONNULL_BEGIN

@interface DBWrapperConfigModel : NSObject

@property (nonatomic, assign) BOOL isReport;
@property (nonatomic, assign) CGFloat sampleFrequency;

@end

NS_ASSUME_NONNULL_END
