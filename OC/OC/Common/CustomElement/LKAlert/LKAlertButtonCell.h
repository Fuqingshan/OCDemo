//
//  LKAlertButtonCell.h
//  App
//
//  Created by yier on 2019/5/16.
//  Copyright © 2019 yooli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCFillCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LKAlertButtonCell : UITableViewCell<OCFillCellProtocol>
@property (nonatomic, copy) VOIDBlockWithModel configBlock;
@property (nonatomic, copy) VOIDBlockWithModel tapBlock;

@end

NS_ASSUME_NONNULL_END
