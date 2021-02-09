//
//  DBXViewDelegate.h
//  CXCommonModule
//
//  Created by didi on 2021/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DBXViewDelegate <NSObject>

@optional

- (void)dbxViewClickedWithAction:(NSString *)action actionParam:(NSDictionary *)actionParam;
- (void)dbxView:(UIView *)dbView clickedWithAction:(NSString *)action actionParam:(NSDictionary *)actionParam;
- (void)dbxViewLongPressedWithAction:(NSString *)action actionParam:(NSDictionary *)actionParam;
- (void)dbxView:(UIView *)dbView longPressedWithAction:(NSString *)action actionParam:(NSDictionary *)actionParam;
- (void)dbxViewScrollEnd:(UIView *)dbView;
- (void)dbxLoadMoreData:(UIView *)dbView actionParam:(nonnull NSDictionary *)actionParam;
- (void)dbxViewExposureWithParam:(NSDictionary *)param;

@end

NS_ASSUME_NONNULL_END
