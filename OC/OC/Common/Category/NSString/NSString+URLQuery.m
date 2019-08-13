//
//  NSString+URLQuery.m
//  App
//
//  Created by yier on 2018/12/19.
//  Copyright © 2018 yier. All rights reserved.
//

#import "NSString+URLQuery.h"

@implementation NSString (URLQuery)

#pragma mark - 把url中的query部分转成dictionary
- (NSDictionary *)params {
    if (self.length == 0) {
        return nil;
    }
    NSString *urlStr = self;
    if ([NSString isContainsChineseCharacter:urlStr]) {
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    NSArray *components = [url.query componentsSeparatedByString:@"&"];
    if (components.count == 0) {
        return nil;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    for (NSString *str in components) {
        NSArray *subComponents = [str componentsSeparatedByString:@"="];
        if (subComponents.count != 2) {
            continue;
        }
        NSString *key = subComponents[0];
        NSString *value = subComponents[1];
        if (!key || !value) {
            continue;
        }
        params[key] = [value stringByRemovingPercentEncoding];
    }
    return params;
}

#pragma mark - 把字典转成URL的参数部分
+ (NSString *)mapDictionaryToURLQueryString:(NSDictionary *)dic
{
    if (!dic) {
        return @"";
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    NSMutableArray *queryItems = [NSMutableArray array];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *queryKey = [NSString stringWithFormat:@"%@", key];
        NSString *queryValue = [NSString stringWithFormat:@"%@", obj];
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:queryKey value:queryValue];
        [queryItems addObject:item];
    }];
    components.queryItems = [queryItems copy];
    
    return components.URL.absoluteString;
}

#pragma marlk - 把querys字典和url转化成NSURLComponents
+ (NSURLComponents *)mapQuerysURLByDictionary:(NSDictionary *)dic url:(NSString *)url{
    if (!dic) {
        return nil;
    }
    if (!url) {
        return nil;
    }
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
    NSMutableArray *queryItems = [NSMutableArray array];

    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *queryKey = [NSString stringWithFormat:@"%@", key];
        NSString *queryValue = [NSString stringWithFormat:@"%@", obj];
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:queryKey value:queryValue];
        [queryItems addObject:item];
    }];
    components.queryItems = [queryItems copy];
    
    return components;
}

@end
