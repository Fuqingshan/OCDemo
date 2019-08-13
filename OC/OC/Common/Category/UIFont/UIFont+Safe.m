//
//  UIFont+Safe.m
//  App
//
//  Created by yier on 2019/1/21.
//  Copyright © 2019 yier. All rights reserved.
//

#import "UIFont+Safe.h"

@implementation UIFont (Safe)

+ (UIFont *)lk_fontWithName:(NSString *)name size:(CGFloat)size{
    UIFont *font = [UIFont fontWithName:nilToEmptyString(name) size:size];
    if (!font) {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}

@end
