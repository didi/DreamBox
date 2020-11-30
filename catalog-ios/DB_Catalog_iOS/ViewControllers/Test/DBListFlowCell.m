//
//  DBListFlowCell.m
//  DB_Catalog_iOS
//
//  Created by fangshaosheng on 2020/11/30.
//  Copyright © 2020 fangshaosheng. All rights reserved.
//

#import "DBListFlowCell.h"
#import "DBTreeView.h"

#define temId  @"flow"

@interface DBListFlowCell ()
@property (nonatomic, strong) DBTreeView *dbview;
@end

@implementation DBListFlowCell

#pragma mark - init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpSubViews];
        [self setUpSubViewsConstraints];
    }
    return self;
}

- (void)setUpSubViews {
    self.contentView.backgroundColor = UIColor.lightGrayColor;
    [self.contentView addSubview:self.dbview];
    
}

- (void)setUpSubViewsConstraints {
    [self.dbview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
}
#pragma mark -
- (void)bindData:(NSDictionary *)ext {
    if (!ext) {
        ext =  [DBListFlowCell ext:temId];
    }
    self.dbview.frame = self.contentView.bounds;
    [self.dbview bindExtensionMetaData:ext];
}


- (DBTreeView *)dbview {
    if (!_dbview) {
        _dbview = [[DBTreeView alloc] init];
        [_dbview loadWithTemplateId:temId accessKey:@"TEST" extData:nil completionBlock:^(BOOL successed, NSError * _Nullable error) {
            
        }];
    }
    return _dbview;
}


+ (NSDictionary *)ext:(NSString*)name {
               
    NSString *string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                                            pathForResource:name ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return dict;
}
@end
