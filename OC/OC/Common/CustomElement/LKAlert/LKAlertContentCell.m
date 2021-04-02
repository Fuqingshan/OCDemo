//
//  LKAlertContentCell.m
//  App
//
//  Created by yier on 2019/5/16.
//  Copyright © 2019 yooli. All rights reserved.
//

#import "LKAlertContentCell.h"
#import "LKAlertModel.h"

@interface LKAlertContentCell()
@property (nonatomic, strong) YYLabel *contentLabel;
@property (nonatomic, strong) LKAlertCellModel *model;

@end

@implementation LKAlertContentCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeightWithModel:(id)model{
    if ([model isKindOfClass:[LKAlertCellModel class]]) {
        LKAlertCellModel *cellModel = model;
        CGFloat cellHeight = labelDistance + cellModel.textLayout.textBoundingSize.height;
        
        return cellHeight;
    }
    return 0;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    if (!self.contentLabel) {
        self.contentLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(labelDistance);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-labelDistance);
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(0.0f);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-labelDistance);
        }];
    }
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[LKAlertCellModel class]]) {
        self.model = model;
        self.contentLabel.textLayout = self.model.textLayout;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
