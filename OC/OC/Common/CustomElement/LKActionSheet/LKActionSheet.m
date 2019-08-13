//
//  LKActionSheet.m
//  App
//
//  Created by yier on 2018/7/25.
//  Copyright © 2018 yier. All rights reserved.
//

#import "LKActionSheet.h"
#import "LKActionSheetTitleCell.h"
#import "LKActionSheetContentCell.h"
#import "LKActionSheetCancleCell.h"

static CGFloat topConstraint = 64.0f;
@interface LKActionSheet()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) LKActionSheetModel *model;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) void (^attributesBlock) (NSInteger index, UILabel *contentLabel,UILabel *detailLabel);
@property (nonatomic, copy) void (^bgBlock) (NSInteger index, UIView *view);
@property (nonatomic, copy) void (^clickedBlock) (NSInteger index);

@end

@implementation LKActionSheet

- (void)dealloc{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createBlackBackgroundView];
    }
    return self;
}

#pragma mark - UI
- (void)createBlackBackgroundView{
    UIView *bg = [UIView new];
    bg.tag = 'LABG';
    bg.backgroundColor = [UIColor blackColor];
    bg.alpha = 0;
    [self addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [bg addGestureRecognizer:tap];
}

#pragma mark - private methods
- (void)setupActionSheet {
    [self.tableView reloadData];
}

- (void)hide {
    if (self.tableView.userInteractionEnabled) {
        self.dismiss();
    }
}

#pragma mark - table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LKActionSheetContentModel *model = objectInArrayAtIndex(self.model.dataSource, indexPath.row);
    switch (model.type) {
        case LKActionSheetTypeTitle:
            return [LKActionSheetTitleCell cellHeight];
        case LKActionSheetTypeContent:
            return [LKActionSheetContentCell cellHeight];
        case LKActionSheetTypeCancle:
            return [LKActionSheetCancleCell cellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LKActionSheetContentModel *model = objectInArrayAtIndex(self.model.dataSource, indexPath.row);
    switch (model.type) {
        case LKActionSheetTypeTitle:
            {
                LKActionSheetTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:[LKActionSheetTitleCell cellReuseIdentifier] forIndexPath:indexPath];
                [cell fillCellWithModel:model indexPath:indexPath];
                !self.bgBlock? : self.bgBlock(indexPath.row, cell.bgView);
                !self.attributesBlock? : self.attributesBlock(indexPath.row, cell.titleLabel,cell.detailLabel);
                return cell;
            }
        case LKActionSheetTypeContent:
        {
            LKActionSheetContentCell *cell = [tableView dequeueReusableCellWithIdentifier:[LKActionSheetContentCell cellReuseIdentifier] forIndexPath:indexPath];
            [cell fillCellWithModel:model indexPath:indexPath];
            BOOL needChangeTop = NO;
            BOOL needChangeBottom = NO;
           if (![self hasTitle] && indexPath.row == 0){
               needChangeTop = YES;
            }
            if ([self hasCancle] && indexPath.row == self.model.dataSource.count - 2) {
                needChangeBottom = YES;
            }else if(![self hasCancle] && indexPath.row == self.model.dataSource.count - 1){
                needChangeBottom = YES;
            }
            
            if (needChangeTop && needChangeBottom) {
                [cell changeAll];
            }else if (needChangeTop && !needChangeBottom){
                [cell changeTop];
            }else if (!needChangeTop && needChangeBottom){
                [cell changeBottom];
            }
            
            !self.bgBlock? : self.bgBlock(indexPath.row, cell.bgView);
            !self.attributesBlock? : self.attributesBlock(indexPath.row, cell.contentLabel,cell.detailLabel);
            return cell;
        }
        case LKActionSheetTypeCancle:
        {
            LKActionSheetCancleCell *cell = [tableView dequeueReusableCellWithIdentifier:[LKActionSheetCancleCell cellReuseIdentifier] forIndexPath:indexPath];
            [cell fillCellWithModel:model indexPath:indexPath];
            !self.bgBlock? : self.bgBlock(indexPath.row, cell.bgView);
            !self.attributesBlock? : self.attributesBlock(indexPath.row, cell.cancleLabel,cell.detailLabel);
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.dismiss();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        !self.clickedBlock? : self.clickedBlock(indexPath.row);
    });
}

- (BOOL)hasTitle{
    for (LKActionSheetContentModel *model in self.model.dataSource) {
        if (model.type == LKActionSheetTypeTitle) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)hasCancle{
    for (LKActionSheetContentModel *model in self.model.dataSource) {
        if (model.type == LKActionSheetTypeCancle) {
            return YES;
        }
    }
    
    return NO;
}

- (CGFloat)calculateActionSheetHeight{
    CGFloat height = 0;
    
    for (LKActionSheetContentModel *model in self.model.dataSource) {
        switch (model.type) {
            case LKActionSheetTypeTitle:
                height += [LKActionSheetTitleCell cellHeight];
                break;
            case LKActionSheetTypeCancle:
                height += [LKActionSheetCancleCell cellHeight];
                break;
            case LKActionSheetTypeContent:
                height += [LKActionSheetContentCell cellHeight];
                break;
            default:
                break;
        }
    }
    return height;
}

#pragma mark - lazy load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.leading.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        
        [_tableView registerNib:[UINib nibWithNibName:[LKActionSheetTitleCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[LKActionSheetTitleCell cellReuseIdentifier]];
        [_tableView registerNib:[UINib nibWithNibName:[LKActionSheetContentCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[LKActionSheetContentCell cellReuseIdentifier]];
        [_tableView registerNib:[UINib nibWithNibName:[LKActionSheetCancleCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[LKActionSheetCancleCell cellReuseIdentifier]];
    }
    return _tableView;
}

- (LKActionSheet * (^) (LKActionSheetModel *model))instance {
    if (!_instance) {
        __weak LKActionSheet *weakSelf = self;
        _instance =  ^(LKActionSheetModel *model) {
            weakSelf.model = model;
            if ([weakSelf calculateActionSheetHeight] <= kMainScreenHeight - topConstraint) {
                weakSelf.tableView.scrollEnabled = NO;
            }
            [weakSelf setupActionSheet];
            return weakSelf;
        };
    }
    return _instance;
}

- (LKActionSheet * (^) (NSString *title,NSArray<NSString *> *contents,NSString *cancle))instanceStr {
    if (!_instance) {
        __weak LKActionSheet *weakSelf = self;
        _instanceStr =  ^(NSString *title,NSArray<NSString *> *contents,NSString *cancle) {
            LKActionSheetModel *actionSheetModel = [LKActionSheetModel new];
            NSMutableArray *dataSource = [NSMutableArray new];
            if ([title isValide]) {
                LKActionSheetContentModel *model = [LKActionSheetContentModel new];
                model.type = LKActionSheetTypeTitle;
                model.content = title;
                [dataSource addObject:model];
            }
            for (NSString *content in contents) {
                LKActionSheetContentModel *model = [LKActionSheetContentModel new];
                model.type = LKActionSheetTypeContent;
                model.content = content;
                [dataSource addObject:model];
            }
            if ([cancle isValide]) {
                LKActionSheetContentModel *model = [LKActionSheetContentModel new];
                model.type = LKActionSheetTypeCancle;
                model.content = cancle;
                [dataSource addObject:model];
            }
            actionSheetModel.dataSource = [dataSource copy];
            weakSelf.model = actionSheetModel;
            if ([weakSelf calculateActionSheetHeight] <= kMainScreenHeight - topConstraint) {
                weakSelf.tableView.scrollEnabled = NO;
            }
            [weakSelf setupActionSheet];
            return weakSelf;
        };
    }
    return _instanceStr;
}

- (LKActionSheet * (^) (void))show {
    if (!_show) {
        __weak LKActionSheet *weakSelf = self;
        _show = ^ {
            [[UIApplication sharedApplication].keyWindow addSubview:weakSelf];
            [weakSelf mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(0);
                make.trailing.mas_equalTo(0);
                make.top.mas_equalTo(0);
                make.bottom.mas_equalTo(0);
            }];
            CGFloat height = [weakSelf calculateActionSheetHeight];
            height = MIN(height, kMainScreenHeight - topConstraint);
            [weakSelf.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
                make.bottom.mas_equalTo(height);
            }];
            [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
            weakSelf.tableView.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25 animations:^{
                [weakSelf viewWithTag:'LABG'].alpha = 0.4;
                [weakSelf.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(0);
                }];
                [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
            }completion:^(BOOL finished) {
                weakSelf.tableView.userInteractionEnabled = YES;
            }];
            
            return weakSelf;
        };
    }
    return _show;
}

- (LKActionSheet * (^) (void))dismiss {
    if (!_dismiss) {
        __weak LKActionSheet *weakSelf = self;
        _dismiss = ^ {
            [UIView animateWithDuration:0.25 animations:^{
                [weakSelf viewWithTag:'LABG'].alpha = 0;
                [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(weakSelf.frame.size.height);
                }];
                [weakSelf.superview layoutIfNeeded];
            } completion:^(BOOL finished) {
                [weakSelf removeFromSuperview];
            }];
            return weakSelf;
        };
    }
    return _dismiss;
}

- (LKActionSheet * (^) (void (^str) (NSInteger index, UILabel *contentLabel,UILabel *detailLabel)))attributedStrs {
    __weak LKActionSheet *weakSelf = self;
    _attributedStrs = ^ (void (^str) (NSInteger index, UILabel *contentLabel,UILabel *detailLabel)) {
        weakSelf.attributesBlock = str;
        [weakSelf.tableView reloadData];
        return weakSelf;
    };
    return _attributedStrs;
}

- (LKActionSheet * (^) (void (^bg) (NSInteger index, UIView *view)))bgColors {
    __weak LKActionSheet *weakSelf = self;
    _bgColors = ^ (void (^bg) (NSInteger index, UIView *view)) {
        weakSelf.bgBlock = bg;
        [weakSelf.tableView reloadData];
        return weakSelf;
    };
    return _bgColors;
}

- (LKActionSheet * (^) (void (^clicked) (NSInteger index)))onClicked {
    __weak LKActionSheet *weakSelf = self;
    _onClicked = ^ (void (^clicked) (NSInteger index)) {
        weakSelf.clickedBlock = clicked;
        return weakSelf;
    };
    return _onClicked;
}

@end
