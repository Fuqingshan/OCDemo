//
//  LKActionSheetContentCell.h
//  App
//
//  Created by yier on 2018/7/25.
//  Copyright © 2018 yier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCFillCellProtocol.h"

@interface LKActionSheetContentCell : UITableViewCell<OCFillCellProtocol>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

- (void)changeTop;
- (void)changeBottom;
- (void)changeAll;
@end
