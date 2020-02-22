//
//  CTFrameParser.h
//  CoreTextDemo
//
//  Created by yier on 2020/1/8.
//  Copyright © 2020 yier. All rights reserved.
//
//用于生成最后绘制界面需要的CTFrameRef
#import <Foundation/Foundation.h>
#import "CoreTextData.h"
#import "CoreTextImageData.h"
#import "CoreTextLinkData.h"
#import "CTFrameParserConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFrameParser : NSObject

+ (CoreTextData *)parseContent:(NSString *)content config:(CTFrameParserConfig *)config;

+ (CoreTextData *)parseTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config;
@end

NS_ASSUME_NONNULL_END
