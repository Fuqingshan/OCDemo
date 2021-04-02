//
//  LKAlert.m
//  App
//
//  Created by yier on 2019/5/15.
//  Copyright © 2019 yooli. All rights reserved.
//

#import "LKAlert.h"

#import "LKAlertTitleCell.h"
#import "LKAlertImgCell.h"
#import "LKAlertContentCell.h"
#import "LKAlertButtonCell.h"
#import "LKAlertSpaceCell.h"

#import "LKAlertCircle.h"

#import "UIView+Animation.h"

@interface LKAlert()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewCH;///<tableView的高度
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (nonatomic, copy) NSArray<NSString *> *cacheButtons;///<用来记录最初的buttons
@property (nonatomic, strong) LKAlertModel *model;
@property (nonatomic, strong) LKAlertCircle *circle;

@property (nonatomic, copy) void (^buttonConfigBlock) (UIButton *btn);
@property (nonatomic, copy) void (^clickedBlock) (NSInteger index);
@property (nonatomic, copy) dispatch_block_t closeClickBlock;

@end

@implementation LKAlert

- (void)dealloc{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
       
    }
    
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.closeBtn.hidden = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:[LKAlertTitleCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[LKAlertTitleCell cellReuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[LKAlertImgCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[LKAlertImgCell cellReuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[LKAlertContentCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[LKAlertContentCell cellReuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[LKAlertButtonCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[LKAlertButtonCell cellReuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[LKAlertSpaceCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[LKAlertSpaceCell cellReuseIdentifier]];
}

+ (instancetype)initFromNib{
    LKAlert *alert = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].firstObject;
    alert.windowLevel = UIWindowLevelAlert+1;
    
    LKAlertCircle *circle = [[LKAlertCircle alloc] init];
    circle.alert = alert;
    alert.circle = circle;
    
    alert.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    
    return alert;
}

+ (instancetype)initWithTitle:(NSString *)title
                       image:(UIImage *)img
                      message:(NSString *)message
                      buttons:(NSArray *)buttons
                      buttonBlock:(void (^)(NSInteger index))buttonBlock{
    LKAlert *alert = [LKAlert initFromNib];
    CGFloat space = [title isValide] || img ? 0 : 15;
    alert.title(title).image(img).space(space).message(message).buttons(buttons).show().buttonConfig(^(UIButton *btn) {
        NSString *buttonName = btn.titleLabel.text;
        NSInteger index = [buttons indexOfObject:buttonName];
        if (index == NSNotFound) {
            return;
        }
        //只有一个按钮时，橘黄色
        if (buttons.count == 1) {
            return;
        }
        //2个按钮时，第一个按钮默认取消，所以是灰色
        if (index == 0) {
            [btn setTitleColor:LKHexColor(0x999999) forState:UIControlStateNormal];
        }
    }).onClick(^(NSInteger index) {
        !buttonBlock?:buttonBlock(index);
    });
    
    return alert;
}

#pragma mark - table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LKAlertCellModel *cellModel = objectInArrayAtIndex(self.model.dataSource, indexPath.row);
    switch (cellModel.type) {
        case LKAlertCellTypeTitle:
            return [LKAlertTitleCell cellHeight];
        case LKAlertCellTypeImg:
            return [LKAlertImgCell cellHeightWithModel:cellModel];
        case LKAlertCellTypeContent:
            return [LKAlertContentCell cellHeightWithModel:cellModel];
        case LKAlertCellTypeButton:
            return [LKAlertButtonCell cellHeight];
        case LKAlertCellTypeSpace:
            return [LKAlertSpaceCell cellHeightWithModel:cellModel];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LKAlertCellModel *cellModel = objectInArrayAtIndex(self.model.dataSource, indexPath.row);
    switch (cellModel.type) {
        case LKAlertCellTypeTitle:
        {
            LKAlertTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:[LKAlertTitleCell cellReuseIdentifier] forIndexPath:indexPath];
            [cell fillCellWithModel:cellModel indexPath:indexPath];
            return cell;
        }
        case LKAlertCellTypeImg:
        {
            LKAlertImgCell *cell = [tableView dequeueReusableCellWithIdentifier:[LKAlertImgCell cellReuseIdentifier] forIndexPath:indexPath];
            [cell fillCellWithModel:cellModel indexPath:indexPath];
            return cell;
        }
        case LKAlertCellTypeContent:
        {
            LKAlertContentCell *cell = [tableView dequeueReusableCellWithIdentifier:[LKAlertContentCell cellReuseIdentifier] forIndexPath:indexPath];
            [cell fillCellWithModel:cellModel indexPath:indexPath];
            return cell;
        }
        case LKAlertCellTypeButton:
        {
            LKAlertButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[LKAlertButtonCell cellReuseIdentifier] forIndexPath:indexPath];
            [cell fillCellWithModel:cellModel indexPath:indexPath];
            [self tableViewCellButtonClick:cell];
            return cell;
        }
        case LKAlertCellTypeSpace:
        {
            LKAlertSpaceCell *cell = [tableView dequeueReusableCellWithIdentifier:[LKAlertSpaceCell cellReuseIdentifier] forIndexPath:indexPath];
            [cell fillCellWithModel:cellModel indexPath:indexPath];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableViewCellButtonClick:(LKAlertButtonCell *)cell{
    @weakify(self);
    cell.tapBlock = ^(id model) {
        @strongify(self);
        if ([model isKindOfClass:[NSString class]]) {
            NSString *buttonName = model;
            NSInteger index = [self.cacheButtons indexOfObject:buttonName];
            if (index == NSNotFound) {
                return;
            }
            self.dismiss();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                !self.clickedBlock? : self.clickedBlock(index);
            });
        }
    };
    
    cell.configBlock = ^(id model) {
      @strongify(self);
        if ([model isKindOfClass:[UIButton class]]) {
            UIButton *btn = model;
            !self.buttonConfigBlock?:self.buttonConfigBlock(btn);
        }
    };
}

- (IBAction)closeEvent:(id)sender {
    self.dismiss();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        !self.closeClickBlock? : self.closeClickBlock();
    });
}

#pragma mark - Instance
- (LKAlert *(^)(CGFloat height))space{
    if (!_space) {
        @weakify(self);
        _space = ^(CGFloat height){
            @strongify(self);
            if (height > 0) {
                LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                cellModel.type = LKAlertCellTypeSpace;
                cellModel.spaceHeight = height;
                [self.model.dataSource addObject:cellModel];
            }
            return self;
        };
    }
    
    return _space;
}

- (LKAlert *(^)(NSString *))title{
    if (!_title) {
        @weakify(self);
        _title = ^(NSString *title){
            @strongify(self);
            if ([title isValide]) {
                LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                cellModel.type = LKAlertCellTypeTitle;
                cellModel.title = title;
                cellModel.titleAlignment = NSTextAlignmentCenter;
                [self.model.dataSource addObject:cellModel];
            }
            
            return self;
        };
    }
    
    return _title;
}

- (LKAlert *(^)(NSString *,NSTextAlignment))titleModifyAlignment{
    if (!_titleModifyAlignment) {
        @weakify(self);
        _titleModifyAlignment = ^(NSString *title,NSTextAlignment titleAlignment){
            @strongify(self);
            if ([title isValide]) {
                LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                cellModel.type = LKAlertCellTypeTitle;
                cellModel.title = title;
                cellModel.titleAlignment = titleAlignment;
                [self.model.dataSource addObject:cellModel];
            }
            
            return self;
        };
    }
    
    return _titleModifyAlignment;
}

- (LKAlert *(^)(UIImage *))image{
    if (!_image) {
        @weakify(self);
        _image = ^(UIImage *image){
            @strongify(self);
            if (image) {
                LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                cellModel.type = LKAlertCellTypeImg;
                cellModel.desImg = image;
                cellModel.imgStyle = LKAlertCellImgStyleSquare;
                [self.model.dataSource addObject:cellModel];
            }
            
            return self;
        };
    }
    
    return _image;
}

- (LKAlert *(^)(UIImage *,LKAlertCellImgStyle))imageModifyStyle{
    if (!_imageModifyStyle) {
        @weakify(self);
        _imageModifyStyle = ^(UIImage *image,LKAlertCellImgStyle imgStyle){
            @strongify(self);
            if (image) {
                LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                cellModel.type = LKAlertCellTypeImg;
                cellModel.desImg = image;
                cellModel.imgStyle = imgStyle;
                [self.model.dataSource addObject:cellModel];
            }
            
            return self;
        };
    }
    
    return _imageModifyStyle;
}

- (LKAlert *(^)(id msg))message{
    if (!_message) {
        @weakify(self);
        _message = ^(id msg){
          @strongify(self);
            if ([msg isKindOfClass:[NSString class]]) {
                NSString *content = msg;
                if ([content isValide]) {
                    LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                    cellModel.type = LKAlertCellTypeContent;
                    cellModel.content = content;
                    [self.model.dataSource addObject:cellModel];
                }
            }else if ([msg isKindOfClass:[YYTextLayout class]]){
                YYTextLayout *textLayout = msg;
                if ([textLayout.text.string isValide]) {
                    LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                    cellModel.type = LKAlertCellTypeContent;
                    cellModel.textLayout = textLayout;
                    [self.model.dataSource addObject:cellModel];
                }
            }
            
            return self;
        };
    }
    
    return _message;
}

- (LKAlert *(^)(NSArray<NSString *> *))buttons{
    if (!_buttons) {
        @weakify(self);
        _buttons = ^(NSArray<NSString *> *buttons){
          @strongify(self);
            self.cacheButtons = buttons;
            if (buttons.count < 3) {
                LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                cellModel.type = LKAlertCellTypeButton;
                cellModel.buttons = buttons;
                [self.model.dataSource addObject:cellModel];
            }else{
                for (NSString *buttonName in buttons) {
                    LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                    cellModel.type = LKAlertCellTypeButton;
                    cellModel.buttons = @[buttonName];
                    [self.model.dataSource addObject:cellModel];
                }
            }
            
            return self;
        };
    }
    
    return _buttons;
}

- (LKAlert *(^)(NSArray<NSString *> *))horizontalButtons{
    if (!_horizontalButtons) {
        @weakify(self);
        _horizontalButtons = ^(NSArray<NSString *> *horizontalButtons){
            @strongify(self);
            self.cacheButtons = horizontalButtons;
            for (NSString *buttonName in horizontalButtons) {
                LKAlertCellModel *cellModel = [[LKAlertCellModel alloc] init];
                cellModel.type = LKAlertCellTypeButton;
                cellModel.buttons = @[buttonName];
                [self.model.dataSource addObject:cellModel];
            }
            
            return self;
        };
    }
    
    return _horizontalButtons;
}

- (LKAlert * (^) (void))show {
    if (!_show) {
        @weakify(self);
        _show = ^ {
            @strongify(self);
            [self configTableViewHeight];
            [LKAlert alphaView:self show:YES completionBlock:nil];
            self.tableView.userInteractionEnabled = NO;
            [LKAlert springView:self.tableView completionBlock:^{
                @strongify(self);
                self.tableView.userInteractionEnabled = YES;
            }];
            //如果展示了closeBtn，增加弹性动画
            if (!self.closeBtn.hidden) {
                [LKAlert springView:self.closeBtn completionBlock:nil];
            }
            
            return self;
        };
    }
    return _show;
}

- (LKAlert *(^)(void (^buttonConfigBlock)(UIButton *btn)))buttonConfig{
    if (!_buttonConfig) {
        @weakify(self);
        _buttonConfig = ^(void (^buttonConfigBlock)(UIButton *btn)){
            @strongify(self);
            self.buttonConfigBlock = buttonConfigBlock;
            return self;
        };
    }
    
    return _buttonConfig;
}

- (LKAlert *(^)(void (^clicked)(NSInteger)))onClick{
    if (!_onClick) {
        @weakify(self);
        _onClick = ^(void (^clicked)(NSInteger)){
            @strongify(self);
            self.clickedBlock = clicked;
            return self;
        };
    }
    
    return _onClick;
}

- (LKAlert *(^)(void))close{
    if (!_close) {
        @weakify(self);
        _close = ^{
            @strongify(self);
            self.closeBtn.hidden = NO;
            return self;
        };
    }
    
    return _close;
}

- (LKAlert *(^)(dispatch_block_t closeClick))onCloseClick{
    if (!_onCloseClick) {
        @weakify(self);
        _onCloseClick = ^(dispatch_block_t closeClick){
          @strongify(self);
            self.closeClickBlock = closeClick;
            return self;
        };
    }
    
    return _onCloseClick;
}

- (LKAlert * (^) (void))dismiss {
    if (!_dismiss) {
        @weakify(self);
        _dismiss = ^ {
            @strongify(self);
            [LKAlert alphaView:self show:NO completionBlock:^{
                @strongify(self);
                //ios9不加这句会导致LKAlert不释放
                [self resignKeyWindow];
                [self removeFromSuperview];
                self.circle = nil;
            }];
            return self;
        };
    }
    return _dismiss;
}

- (void)configTableViewHeight{
    CGFloat height = 0;
    for (LKAlertCellModel *cellModel in self.model.dataSource) {
        switch (cellModel.type) {
            case LKAlertCellTypeTitle:
                height += [LKAlertTitleCell cellHeight];
                break;
            case LKAlertCellTypeImg:
                height += [LKAlertImgCell cellHeightWithModel:cellModel];
                break;
            case LKAlertCellTypeContent:
                height += [LKAlertContentCell cellHeightWithModel:cellModel];
                break;
            case LKAlertCellTypeButton:
                height += [LKAlertButtonCell cellHeight];
                break;
            case LKAlertCellTypeSpace:
                height += [LKAlertSpaceCell cellHeightWithModel:cellModel];
                break;
        }
    }
    
    self.tableViewCH.constant = height;
    [self layoutIfNeeded];
    [self.tableView reloadData];
    [UIView addRoundedByView:self.tableView Corners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight withRadii:CGSizeMake(8, 8) viewRect:CGRectMake(0, 0, kMainScreenWidth - tableViewDistance * 2, height)];
}

#pragma mark - animation
+ (void)springView:(UIView *)view completionBlock:(dispatch_block_t)completionBlock{
    CGFloat alpha = view.alpha;
    view.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.alpha = alpha;
    } completion:^(BOOL finished) {
        !completionBlock?:completionBlock();
    }];
}

+ (void)alphaView:(UIView *)view show:(BOOL)show completionBlock:(dispatch_block_t)completionBlock{
    view.alpha = show?0:1;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = !show?0:1;
    } completion:^(BOOL finished) {
        !completionBlock?:completionBlock();
    }];
}

#pragma mark - lazy load
- (LKAlertModel *)model{
    if(!_model){
        _model = [[LKAlertModel alloc] init];
        _model.dataSource = [[NSMutableArray alloc] init];
    }
    return _model;
}

@end
