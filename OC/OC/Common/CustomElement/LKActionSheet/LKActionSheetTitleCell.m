//
//  LKActionSheetTitleCell.m
//  App
//
//  Created by yier on 2018/7/25.
//  Copyright © 2018 yier. All rights reserved.
//

#import "LKActionSheetTitleCell.h"
#import "UIView+Animation.h"
#import "LKActionSheetModel.h"

@interface LKActionSheetTitleCell()
@property (nonatomic, strong) LKActionSheetContentModel *model;
@end

@implementation LKActionSheetTitleCell

+ (CGFloat)cellHeight{
    return 45.0f;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [UIView addRoundedByView:self.bgView Corners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(13, 13) viewRect:CGRectMake(0, 0, kMainScreenWidth - 20, 45.0f)];
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[LKActionSheetContentModel class]]) {
        self.model = model;
        self.titleLabel.text = nilToEmptyString(self.model.content);
        self.detailLabel.text = nilToEmptyString(self.model.detail);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
