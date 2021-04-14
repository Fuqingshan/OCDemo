//
//  GPUImageBeautifyFilter.h
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.
//
//https://github.com/Guikunzhi/BeautifyFaceDemo

#import <LFLiveKit/GPUImageFilterGroup.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBeautifyFilter : GPUImageFilterGroup

// 美颜的强度 (0~1, 默认 0.5)
@property (nonatomic, assign) CGFloat intensity;

@end

NS_ASSUME_NONNULL_END
