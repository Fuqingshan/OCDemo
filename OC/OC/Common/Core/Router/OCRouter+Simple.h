//
//  OCRouter+Simple.h
//  App
//
//  Created by yier on 2019/1/22.
//  Copyright © 2019 yier. All rights reserved.
//
//Simple相关的路由

#import "OCRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCRouter (Simple)

/**
 处理Simple相关的router

 @param url Simple相关的url
 @return 成功处理返回YES，没有对应的跳转返回NO
 */
+ (BOOL)openSimpleURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
