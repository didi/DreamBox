//
//  DBMyView.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/31.
//

#import "DBMyView.h"
#import "Masonry.h"

@implementation DBMyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setDataWithModel:(DBViewModel *)model andPathId:(NSString *)pathId {
    [super setDataWithModel:model andPathId:pathId];

    DBTreeView *treeView1 = [DBTreeView treeViewWithRender:model.children accessKey:self.accessKey tid:self.tid];
    DBTreeView *treeView2 = [DBTreeView treeViewWithRender:model.children accessKey:self.accessKey tid:self.tid];
    [self addSubview:treeView1];
    [self addSubview:treeView2];

//    treeView1.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 120);
//    treeView2.frame = CGRectMake(0, 120, [UIScreen mainScreen].bounds.size.width, 120);
    [treeView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(120);
    }];
    [treeView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.mas_equalTo(treeView1.mas_bottom).offset(120);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(120);
    }];
    
    treeView1.backgroundColor = [UIColor blueColor];
    treeView2.backgroundColor = [UIColor greenColor];
}
//

@end

@implementation DBMyView1

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setDataWithModel:(DBViewModel *)model andPathId:(NSString *)pathId {
    DBTreeView *treeView1 = [DBTreeView treeViewWithRender:model.children meta:nil accessKey:self.accessKey tid:self.tid];
        [self addSubview:treeView1];
//    treeView1.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30);
    [treeView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(30);
    }];
    treeView1.backgroundColor = [UIColor orangeColor];
}
//


@end


@implementation DBMyTestView
-(void)setDataWithModel:(DBViewModel *)model andPathId:(NSString *)pathId {
    UIView *bgView = [UIView new];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.mas_equalTo(self);
    }];
    
    bgView.backgroundColor = [UIColor yellowColor];
    
    UIView *view1 = [UIView new];
    view1.backgroundColor = [UIColor blueColor];
//    [bgView addSubview:view1];
    UIView *view2 = [UIView new];
    view2.backgroundColor = [UIColor purpleColor];
//    [bgView addSubview:view2];
    UIView *view3 = [UIView new];
    view3.backgroundColor = [UIColor orangeColor];
    [bgView addSubview:view3];
    
    UIView *view4 = [UIView new];
    view4.backgroundColor = [UIColor redColor];
    

    [view3 addSubview:view1];
    [view3 addSubview:view2];
    [view3 addSubview:view4];
    //view1的约束：top相对父亲, offset = 5，有自己的高
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view3).offset(10);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(100);
        make.top.mas_equalTo(view3).offset(5);
    }];
    
    //view2的约束：top相对view1,offset = 5，有自己的高
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view3).offset(10);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(100);
        make.top.mas_equalTo(view1.mas_bottom).offset(5);
        make.bottom.mas_equalTo(view3.mas_bottom);
    }];
    
    [view3 setNeedsLayout];
    [view3 layoutIfNeeded];
    
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(bgView);
        make.centerY.mas_equalTo(bgView.mas_centerY);
        make.height.mas_equalTo(view3.mas_height);
    }];
    
    
    [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view3).offset(10);
        make.height.mas_equalTo(20).priorityHigh();
        make.width.mas_equalTo(100).priorityHigh();
        make.centerY.mas_equalTo((CGRectGetMinY(view1.frame) + CGRectGetMaxY(view2.frame))/2);
    }];
    
    
}

@end
