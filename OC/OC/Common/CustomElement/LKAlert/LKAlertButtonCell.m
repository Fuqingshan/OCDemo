//
//  LKAlertButtonCell.m
//  App
//
//  Created by yier on 2019/5/16.
//  Copyright © 2019 yooli. All rights reserved.
//

#import "LKAlertButtonCell.h"
#import "LKAlertModel.h"

@interface LKAlertButtonCell()
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (nonatomic, strong) LKAlertCellModel *model;
@end

@implementation LKAlertButtonCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeight{
    return 40.0;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[LKAlertCellModel class]]) {
        self.model = model;
        [self.stackView removeAllSubviews];
        [self configButtons];
    }
}

- (void)configButtons{
    if (self.model.buttons == 0 || self.model.buttons.count > 2) {
        return;
    }
    
    for (NSString *btnName in self.model.buttons) {
        UIButton *btn = [[UIButton alloc] init];
        btn.titleLabel.font = PingFangSCRegular(17.0f);
        [btn setBackgroundColor:[UIColor whiteColor]];
        [btn setTitle:nilToEmptyString(btnName) forState:UIControlStateNormal];
        [btn setTitleColor:LKHexColor(0xFC8936) forState:UIControlStateNormal];
        [self.stackView addArrangedSubview:btn];
        !self.configBlock?:self.configBlock(btn);
        @weakify(self);
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            !self.tapBlock?:self.tapBlock(btnName);
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
