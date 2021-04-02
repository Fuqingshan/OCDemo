//
//  LKAlertTitleCell.m
//  App
//
//  Created by yier on 2019/5/15.
//  Copyright © 2019 yooli. All rights reserved.
//

#import "LKAlertTitleCell.h"
#import "LKAlertModel.h"

@interface LKAlertTitleCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) LKAlertCellModel *model;
@end

@implementation LKAlertTitleCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeight{
    return 40.0f;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[LKAlertCellModel class]]) {
        self.model = model;
        self.titleLabel.text = nilToEmptyString(self.model.title);
        self.titleLabel.textAlignment = self.model.titleAlignment;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
