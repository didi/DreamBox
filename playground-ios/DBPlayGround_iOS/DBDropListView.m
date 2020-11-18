//
//  DDIMDropListView.m
//  Pods
//
//  Created by didi on 16/12/20.
//
//

#import "DBDropListView.h"

static CGFloat kRowHeight = 50;
static CGFloat kSectionHeight = 0;

@interface DBDropListView()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, assign) BOOL isShow;          //在动画完成时记录展示状态，防止展开收起动画冲突
@property (nonatomic, assign) CGRect showRect;      //展开rect
@property (nonatomic, assign) CGRect dismissRect;   //收起rect
@property (nonatomic, copy) NSArray *selections;    //选项数据源
@property (nonatomic, copy) void(^selectBlock)(NSInteger index, NSString *selectedId);

@end

@implementation DBDropListView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame selections:(NSArray *)selections selectBlock:(void(^)(NSInteger index, NSString *selectedId))selectBlock
{
    if(self = [super init])
    {
        //阴影
        self.layer.shadowOffset = CGSizeMake(4.0f, 1.0f);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.08f;
        self.layer.shadowRadius = 3;
        
        //初始化样式
        self.delegate = self;
        self.dataSource = self;
        self.rowHeight = kRowHeight;
        self.bounces = NO;
        self.frame = frame;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];

        //初始化属性
        _isShow = NO;
        _dismissRect = frame;
        _selections = selections;
        _selectBlock = selectBlock;
        CGFloat height = 100;
        if(_selections.count > 0){
            height = _selections.count * kRowHeight + kSectionHeight;
        }
        _showRect = CGRectMake(_dismissRect.origin.x, _dismissRect.origin.y, _dismissRect.size.width, height);
    }
    return self;
}

#pragma mark - publicMethods
- (void)showWithButton:(UIButton *)btn
{
    if(_isShow)
    {
        return;
    }
    
    if(![self isShown])
    {
        [self.superview bringSubviewToFront:self];
        self.frame = CGRectMake(_dismissRect.origin.x, _dismissRect.origin.y, _dismissRect.size.width, 0);
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = _showRect;
        } completion:^(BOOL finished) {
            self.frame = _showRect;
            _isShow = YES;
            btn.selected = YES;
        }];
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"
#pragma clang diagnostic ignored "-Wmismatched-return-types"
- (void)dismissWithButton:(UIButton *)btn
#pragma clang diagnostic pop
{
    if(!_isShow)
    {
        return;
    }
    
    if([self isShown])
    {
        self.frame = _showRect;
        self.frame = _dismissRect;
        _isShow = NO;
        btn.selected = NO;
    }
}

- (BOOL)isShown
{
    return self.frame.size.height == _showRect.size.height;
}

- (void)setSelections:(NSArray *)selections {
    _selections = selections;
    CGFloat height = 100;
    if(_selections.count > 0){
        height = _selections.count * kRowHeight + kSectionHeight;
    }
    _showRect = CGRectMake(_dismissRect.origin.x, _dismissRect.origin.y, _dismissRect.size.width, height);
    [self reloadData];
}

#pragma mark - delegates
#pragma mark -- UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _selections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kSectionHeight)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //下拉列表中只有很少几条，不需复用，直接创建即可
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    NSString *text = _selections[indexPath.row];
    
    //文字
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 16.5, _showRect.size.width, 17)];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.text = text;
    contentLabel.font = [UIFont systemFontOfSize:17];
    contentLabel.textColor = [UIColor blackColor];
    [cell.contentView addSubview:contentLabel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = _selections[indexPath.row];
    _selectBlock(indexPath.row, text);
}
@end
