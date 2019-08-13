//
//  SettingLanguageCell.m
//  OC
//
//  Created by yier on 2019/2/14.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SettingLanguageCell.h"

@interface SettingLanguageCell()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

@end

@implementation SettingLanguageCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeight{
    return 50.0f;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    // Initialization code
}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    switch ([LanguageManager shareInstance].type) {
        case LanguageTypeCH:
            self.switchBtn.on = YES;
            break;
        case LanguageTypeEN:
            self.switchBtn.on = NO;
            break;
    }
    self.contentLabel.text = LocalizedString(@"中文");
}

#pragma mark - Event
- (IBAction)switchEvent:(id)sender {
    if (self.switchBtn.on) {
        [[LanguageManager shareInstance] setUserlanguage:LanguageTypeEN];
    }else{
        [[LanguageManager shareInstance] setUserlanguage:LanguageTypeCH];
    }
    self.switchBtn.on = !self.switchBtn.on;
    self.contentLabel.text = LocalizedString(@"中文");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
