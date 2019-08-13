//
//  UIControlHeader.m
//  OC
//
//  Created by yier on 2019/3/14.
//  Copyright © 2019 yier. All rights reserved.
//

#import "UIControlHeader.h"

@implementation UIControlHeader

- (void)dealloc{
    
}

+ (CGFloat)cellHeight{
    return 200*kMainScreenWidth/375.0;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib{
    [super awakeFromNib];
}


@end
