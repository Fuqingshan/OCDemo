//
//  AutomaticDimensionCell.m
//  OC
//
//  Created by yier on 2019/3/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "AutomaticDimensionCell.h"

@interface AutomaticDimensionCell()

@end

@implementation AutomaticDimensionCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeight{
    return 100;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = model;
        NSString *img = stringInDictionaryForKey(dic, @"photo");
        NSString *title = stringInDictionaryForKey(dic, @"name");
        NSString *content = stringInDictionaryForKey(dic, @"content");
        [self.photo sd_setImageWithURL:[NSURL URLWithString:img]];
        self.title.text = title;
        self.content.text = content;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
