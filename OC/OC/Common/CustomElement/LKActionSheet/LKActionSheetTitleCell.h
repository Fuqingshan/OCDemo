//
//  LKActionSheetTitleCell.h
//  App
//
//  Created by yier on 2018/7/25.
//  Copyright © 2018 yier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCFillCellProtocol.h"

@interface LKActionSheetTitleCell : UITableViewCell<OCFillCellProtocol>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
