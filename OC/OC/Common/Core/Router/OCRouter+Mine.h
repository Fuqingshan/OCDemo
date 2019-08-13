//
//  OCRouter+Mine.h
//  OC
//
//  Created by yier on 2019/3/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCRouter (Mine)

/**
 处理Mine相关的router
 
 @param url Mine相关的url
 @return 成功处理返回YES，没有对应的跳转返回NO
 */
+ (BOOL)openMineURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
