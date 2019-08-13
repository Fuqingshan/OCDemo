//
//  LKActionSheetContentCell.m
//  App
//
//  Created by yier on 2018/7/25.
//  Copyright © 2018 yier. All rights reserved.
//

#import "LKActionSheetContentCell.h"
#import "LKActionSheetModel.h"
#import "UIView+Animation.h"

@interface LKActionSheetContentCell()
@property (nonatomic, strong) LKActionSheetContentModel *model;
@end

@implementation LKActionSheetContentCell

+ (CGFloat)cellHeight{
    return 57.0f;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)changeTop{
    [UIView addRoundedByView:self.bgView Corners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(13, 13) viewRect:CGRectMake(0, 0, kMainScreenWidth - 20, 57.0f)];
}

- (void)changeBottom{
    [UIView addRoundedByView:self.bgView Corners:UIRectCornerBottomLeft|UIRectCornerBottomRight withRadii:CGSizeMake(13, 13) viewRect:CGRectMake(0, 0, kMainScreenWidth - 20, 57.0f)];
}

- (void)changeAll{
     [UIView addRoundedByView:self.bgView Corners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight withRadii:CGSizeMake(13, 13) viewRect:CGRectMake(0, 0, kMainScreenWidth - 20, 57.0f)];
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[LKActionSheetContentModel class]]) {
        self.model = model;
        self.contentLabel.text = nilToEmptyString(self.model.content);
        self.detailLabel.text = nilToEmptyString(self.model.detail);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
