//
//  AutomaticDimensionCell.h
//  OC
//
//  Created by yier on 2019/3/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCFillCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AutomaticDimensionCell : UITableViewCell<OCFillCellProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *content;

@end

NS_ASSUME_NONNULL_END
