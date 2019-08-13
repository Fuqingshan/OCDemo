//
//  PropertyCell.m
//  OC
//
//  Created by yier on 2019/2/18.
//  Copyright © 2019 yier. All rights reserved.
//

#import "PropertyCell.h"

@interface PropertyCell()
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@end

@implementation PropertyCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeightWithModel:(NSString *)des{
    CGFloat height = [nilToEmptyString(des) boundingRectWithSize:CGSizeMake(kMainScreenWidth - 220-(12+5), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:PingFangSCRegular(14.0f)} context:nil].size.height;
    height = MAX(height, 50.0f);
    return height;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = model;
        NSString *type = stringInDictionaryForKey(dic, @"type");
        NSString *property = stringInDictionaryForKey(dic, @"property");
        NSString *des = stringInDictionaryForKey(dic, @"des");
        self.typeLabel.text = type;
        self.propertyLabel.text = property;
        self.desLabel.text = des;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
