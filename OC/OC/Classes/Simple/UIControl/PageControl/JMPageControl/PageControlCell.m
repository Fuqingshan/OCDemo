//
//  PageControlCell.m
//  JMPageControl
//
//  Created by yier on 2018/2/22.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "PageControlCell.h"
#import "PageControlModel.h"
#import "PageControlDefine.h"

@interface PageControlCell()
@end

@implementation PageControlCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pointView.layer.cornerRadius = CellHeight/2;
}

- (void)updateUIWithModel:(id)model{
    if ([model isKindOfClass:[PageControlModel class]]) {
        self.model = model;
        [self setPointViewUIByPageControlModel:self.model];
    }
}

- (void)setPointViewUIByPageControlModel:(PageControlModel *)model{
    switch (model.type) {
        case PageControlUITypeOval:
        {
            self.pointWC.constant = CellWidth;
            self.pointView.backgroundColor = [UIColor lk_alphaColorWithHexString:@"0xFF1C1C1C"];
        }
            break;
        default:
        {
            self.pointWC.constant = CellHeight;
            self.pointView.backgroundColor = [UIColor lk_alphaColorWithHexString:@"0x99999999"];
        }
            break;
    }
}

+ (NSString *)cellIdentifier{
    return NSStringFromClass([self class]);
}
@end
