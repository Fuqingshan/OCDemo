//
//  LKAlertImgCell.m
//  App
//
//  Created by yier on 2019/5/16.
//  Copyright © 2019 yooli. All rights reserved.
//

#import "LKAlertImgCell.h"
#import "LKAlertModel.h"

@interface LKAlertImgCell()
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (nonatomic, strong) LKAlertCellModel *model;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWC;
@end

@implementation LKAlertImgCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeightWithModel:(id)model{
    if ([model isKindOfClass:[LKAlertCellModel class]]) {
        LKAlertCellModel *cellModel = model;
        if (cellModel.imgStyle == LKAlertCellImgStyleSquare) {
            return defaultImgHeight;
        }
        return MAX(cellModel.desImg.size.height, defaultImgHeight);
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
    if ([model isKindOfClass:[LKAlertCellModel class]]) {
        self.model = model;
        self.img.image = self.model.desImg;
        if (self.model.imgStyle == LKAlertCellImgStyleSquare) {
            self.imgWC.constant = defaultImgHeight;
        }else{
            self.imgWC.constant = kMainScreenWidth;
        }
        [self.contentView layoutIfNeeded];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
