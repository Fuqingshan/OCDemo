//
//  TagsViewCell.h
//  searchBar
//
//  Created by yier on 16/7/7.
//  Copyright © 2016年 yier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCFillCellProtocol.h"
@interface TagsViewCell : UICollectionViewCell<OCFillCellProtocol>

@property (weak, nonatomic) IBOutlet UILabel *tagName;
@end
