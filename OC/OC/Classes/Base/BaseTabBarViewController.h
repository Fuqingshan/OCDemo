//
//  BaseTabBarViewController.h
//  OC
//
//  Created by yier on 2019/2/13.
//  Copyright © 2019 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TabBarItemType) {
    TabBarItemTypeSimple = 0,
    TabBarItemTypeAdvance,
    TabBarItemTypePractice,
};

@interface BaseTabBarViewController : UITabBarController
@property (nonatomic, assign) TabBarItemType itemType;

@end

NS_ASSUME_NONNULL_END
