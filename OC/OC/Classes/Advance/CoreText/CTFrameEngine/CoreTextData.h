//
//  CoreTextData.h
//  CoreTextDemo
//
//  Created by yier on 2020/1/8.
//  Copyright © 2020 yier. All rights reserved.
//
//用于保存由CTFrameParser类生成的CTFrameRef实例，以及CTFrameRef实际绘制需要的高度
#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CoreTextImageData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreTextData : NSObject

@property(nonatomic, assign) CTFrameRef ctFrame;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, strong) NSMutableArray *imageArray;
@property(nonatomic, strong) NSMutableArray *linkArray;

@end

NS_ASSUME_NONNULL_END
