//
//  LKActionSheetCancleCell.m
//  App
//
//  Created by yier on 2018/7/25.
//  Copyright © 2018 yier. All rights reserved.
//

#import "LKActionSheetCancleCell.h"
#import "LKActionSheetModel.h"

@interface LKActionSheetCancleCell()
@property (nonatomic, strong) LKActionSheetContentModel *model;
@end

@implementation LKActionSheetCancleCell

+ (CGFloat)cellHeight{
    return 77.0f;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 13.0f;
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[LKActionSheetContentModel class]]) {
        self.model = model;
        self.cancleLabel.text = nilToEmptyString(self.model.content);
        self.detailLabel.text = nilToEmptyString(self.model.detail);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
