//
//  UIControlHeader.h
//  OC
//
//  Created by yier on 2019/3/14.
//  Copyright © 2019 yier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCFillCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIControlHeader : UITableViewHeaderFooterView<OCFillCellProtocol>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgCH;

@end

NS_ASSUME_NONNULL_END
