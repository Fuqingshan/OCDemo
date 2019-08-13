//
//  BaseTabBar.h
//  OC
//
//  Created by yier on 2019/2/13.
//  Copyright © 2019 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ThemeStyle) {
    ThemeStyleName,///<你的名字
    ThemeStyleWriter,///<英语模式展示的样子
};

@interface BaseTabBar : UITabBar

- (void)getBaseItemsByTabBarItems:(NSArray<UITabBarItem *> *)items;

@end

NS_ASSUME_NONNULL_END
