//
//  OCRouterFastCreate.m
//  App
//
//  Created by yier on 2019/1/29.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouterFastCreate.h"
#import "NSString+URLQuery.h"

@implementation OCRouterFastCreate

#pragma mark - 快速创建OCweb所需要的url
+ (NSURL *)fastCreateOCWebURLByH5:(NSString *)urlStr{
    NSMutableDictionary *params = [urlStr.params mutableCopy];
    [params addEntriesFromDictionary:@{
                                       @"urlStr":nilToEmptyString(urlStr)
                                       }];
    NSURL *url = [NSString mapQuerysURLByDictionary:params url:@"sumup://mall/web"].URL;
    return url;
}

#pragma mark 快速创建商品分组所需要的url
+ (NSURL *)fastCreateMallGroupURLByH5:(NSString *)urlStr{
    NSMutableDictionary *params = [urlStr.params mutableCopy];
    NSString *isShowPopToRoot = [urlStr containsString:@"pageType=1"]?@"1":@"0";
    [params addEntriesFromDictionary:@{
                                       @"urlStr":nilToEmptyString(urlStr)
                                       ,@"isShowPopToRoot":isShowPopToRoot
                                       ,@"ignoreWebTitle":@"1"
                                       }];
    NSURL *url = [NSString mapQuerysURLByDictionary:params url:@"sumup://mall/web"].URL;
    return url;
}


@end
