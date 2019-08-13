//
//  BaseViewController.h
//  OC
//
//  Created by yier on 2019/2/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
@property (nonatomic, strong, readonly) UIImageView *background;

- (void)changeLanguageEvent;
@end

NS_ASSUME_NONNULL_END
