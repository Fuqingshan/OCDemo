//
//  LKAlertModel.m
//  App
//
//  Created by yier on 2019/5/16.
//  Copyright © 2019 yooli. All rights reserved.
//

#import "LKAlertModel.h"

@implementation LKAlertCellModel

+ (NSArray *)modelPropertyBlacklist {
    return @[@"textLayout"];
}

- (void)setContent:(NSString *)content{
    _content = content;
    
    NSMutableAttributedString *attContent = [[NSMutableAttributedString alloc] initWithString:content];
    attContent.yy_font = PingFangSCRegular(15.0f);
    attContent.yy_color = LKHexColor(0xB2000000);
    attContent.yy_alignment = NSTextAlignmentCenter;
    
    self.textLayout = [LKAlertCellModel calculateTextLayoutByAttributedString:attContent];
}



+ (YYTextLayout *)calculateTextLayoutByAttributedString:(NSMutableAttributedString *)attContent{
    //UI左右间隔(75+15) * 2
    CGFloat cellWidth = kMainScreenWidth - (tableViewDistance + labelDistance) * 2;
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(cellWidth, MAXFLOAT) insets:UIEdgeInsetsMake(0, 0, 0, 0)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:attContent];
    return textLayout;
}

@end

@implementation LKAlertModel

@end
