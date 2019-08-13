//
//  UIFont+Safe.h
//  App
//
//  Created by yier on 2019/1/21.
//  Copyright © 2019 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Safe)

+ (UIFont *)lk_fontWithName:(NSString *)name size:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
