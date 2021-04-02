//
//  LKAlertSpaceCell.m
//  App
//
//  Created by yier on 2019/5/16.
//  Copyright © 2019 yooli. All rights reserved.
//

#import "LKAlertSpaceCell.h"
#import "LKAlertModel.h"

@interface LKAlertSpaceCell()

@end

@implementation LKAlertSpaceCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeightWithModel:(id)model{
    if ([model isKindOfClass:[LKAlertCellModel class]]) {
        LKAlertCellModel *cellModel = model;
        CGFloat cellHeight = cellModel.spaceHeight;
        
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
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
