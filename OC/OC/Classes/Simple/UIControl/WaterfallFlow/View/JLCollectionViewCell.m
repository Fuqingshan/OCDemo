//
//  JLCollectionViewCell.m
//  JLWaterfallFlow
//
//  Created by Jasy on 16/1/25.
//  Copyright © 2016年 Jasy. All rights reserved.
//

#import "JLCollectionViewCell.h"
#import "DataModel.h"
@implementation JLCollectionViewCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeight{
    return 0.0f;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[WaterfallFlowDataUnitModel class]]) {
        WaterfallFlowDataUnitModel *dataModel = model;
//        [self.cellImg sd_setImageWithURL:[NSURL URLWithString:dataModel.img]];
        [self.cellImg sd_setImageWithURL:[NSURL URLWithString:@"https://ws3.sinaimg.cn/large/006tNbRwgy1fy3rvsnzsbj30dw099mx5.jpg"]];
        
        self.priceLa.text = dataModel.price;
    }
}

@end
