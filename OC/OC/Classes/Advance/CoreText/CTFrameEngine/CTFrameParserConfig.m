//
//  CTFrameParserConfig.m
//  CoreTextDemo
//
//  Created by yier on 2020/1/8.
//  Copyright © 2020 yier. All rights reserved.
//

#import "CTFrameParserConfig.h"

@implementation CTFrameParserConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _width = 200.f;
        _fontSize = 16.0f;
        _lineSpace = 8.0f;
        _textColor = LKHexColor(0x6C6C6C);
    }
    return self;
}

@end
