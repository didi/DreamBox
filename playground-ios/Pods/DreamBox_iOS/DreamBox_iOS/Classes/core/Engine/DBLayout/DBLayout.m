//
//  DBLayout.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/7/22.
//

#import "DBLayout.h"

@implementation DBLayout

+ (void)edgeLayoutTargetView:(UIView *)targetView withReferenceView:(UIView *)referenceView edgeInset:(UIEdgeInsets)edgeInset{
    targetView.translatesAutoresizingMaskIntoConstraints = NO;
    referenceView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *viewConstraint = [NSLayoutConstraint constraintWithItem:targetView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:referenceView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:edgeInset.left ? edgeInset.left : 0];
    viewConstraint.active = YES;

    NSLayoutConstraint *viewConstraint2 = [NSLayoutConstraint constraintWithItem:targetView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:referenceView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-(edgeInset.right ? edgeInset.right : 0)];
    viewConstraint2.active = YES;
    
    NSLayoutConstraint *viewConstraint3 = [NSLayoutConstraint constraintWithItem:targetView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:referenceView attribute:NSLayoutAttributeTop multiplier:1.0 constant:edgeInset.top ? edgeInset.top : 0];
    viewConstraint3.active = YES;
    
    NSLayoutConstraint *viewConstraint4 = [NSLayoutConstraint constraintWithItem:targetView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:referenceView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-(edgeInset.bottom ? edgeInset.bottom : 0)];
    viewConstraint4.active = YES;
}

@end
