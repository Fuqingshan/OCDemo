//
//  JLCollectionViewCell.h
//  JLWaterfallFlow
//
//  Created by Jasy on 16/1/25.
//  Copyright © 2016年 Jasy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCFillCellProtocol.h"

@interface JLCollectionViewCell : UICollectionViewCell<OCFillCellProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *cellImg;
@property (weak, nonatomic) IBOutlet UILabel *priceLa;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;

@end
