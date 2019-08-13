//
//  OCRouterFastCreate.h
//  App
//
//  Created by yier on 2019/1/29.
//  Copyright © 2019 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCRouterFastCreate : NSObject

/**
 快速创建OCweb所需要的url
 */
+ (NSURL *)fastCreateOCWebURLByH5:(NSString *)urlStr;

/**
 快速创建商品分组所需要的url
 */
#pragma mark
+ (NSURL *)fastCreateMallGroupURLByH5:(NSString *)urlStr;

@end

NS_ASSUME_NONNULL_END
