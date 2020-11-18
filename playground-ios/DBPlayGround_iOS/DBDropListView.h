//
//  DDIMDropListView.h
//  Pods
//
//  Created by didi on 16/12/20.
//
//

#import <UIKit/UIKit.h>

extern NSString * const kNotification_ButtonSelectedChanged;

@interface DBDropListView : UITableView

/**
 初始化下拉菜单

 @param frame  初始位置
 @param selections 选项数组
 @param selectBlock 点击某个index回调
 */
- (instancetype)initWithFrame:(CGRect)frame selections:(NSArray *)selections selectBlock:(void(^)(NSInteger index, NSString *selectedId))selectBlock;


- (void)setSelections:(NSArray *)selections;

/*!
 * 外部判断当前下拉菜单的展示状态
 */
- (BOOL)isShown;


/*!
 * 展开下拉菜单
 * param btn:吊起此下拉菜单的按钮
 */
- (void)showWithButton:(UIButton *)btn;


/*!
 * 收起下拉菜单
 * param btn:吊起此下拉菜单的按钮
 */
- (BOOL)dismissWithButton:(UIButton *)btn;
@end
