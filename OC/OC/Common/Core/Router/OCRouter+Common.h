//
//  OCRouter+Common.h
//  App
//
//  Created by yier on 2019/1/22.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCRouter (Common)

/**
 跳转Storyboard的controller
 */
+ (void)showViewControllerByIdentifier:(NSString *)identifier storyboardName:(NSString *)storyboardName;

/**
 处理Common相关的router

 @param url Common相关的url
 @return 成功处理返回YES，没有对应的跳转返回NO
 */
+ (BOOL)openCommonURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
