//
//  CTContentView.h
//  CoreTextDemo
//
//  Created by yier on 2020/1/8.
//  Copyright © 2020 yier. All rights reserved.
//
//持有CoreTextData实例，负责将CTFrameRef绘制到界面上
#import <UIKit/UIKit.h>
#import "CoreTextData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTContentView : UIView
@property(nonatomic, strong) CoreTextData *data;

@end

NS_ASSUME_NONNULL_END
