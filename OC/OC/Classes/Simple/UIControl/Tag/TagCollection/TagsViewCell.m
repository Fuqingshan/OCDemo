//
//  TagsViewCell.m
//  searchBar
//
//  Created by yier on 16/7/7.
//  Copyright © 2016年 yier. All rights reserved.
//

#import "TagsViewCell.h"

@implementation TagsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(CGFloat)cellHeight
{
    return 26;
}

+(NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath
{
    
}

@end
