//
//  CTFrameParserConfig.h
//  CoreTextDemo
//
//  Created by yier on 2020/1/8.
//  Copyright © 2020 yier. All rights reserved.
//
//配置绘制参数，如文字颜色、大小、行间距
#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTFrameParserConfig : NSObject
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat fontSize;
@property(nonatomic, assign) CGFloat lineSpace;
@property(nonatomic, strong) UIColor *textColor;

@end

NS_ASSUME_NONNULL_END
