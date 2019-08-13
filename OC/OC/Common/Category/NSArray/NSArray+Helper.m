//
//  NSArray+Helper.m
//  App
//
//  Created by chenfei on 24/11/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#import "NSArray+Helper.h"

@implementation NSArray (Helper)

+ (instancetype)arrayWithJson:(NSString *)json
{
    if (json == nil) return nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:kNilOptions
                                                      error:NULL];
    if ([jsonObject isKindOfClass:[NSArray class]])
        return jsonObject;
    return nil;
}

- (NSString *)toJSONString
{
    if (!self) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json;
}

- (NSArray *)map:(id (^)(id))transform
{
    if (!transform) {
        return nil;
    }

    NSMutableArray *mappedArray = [NSMutableArray arrayWithCapacity:self.count];
    for (id element in self) {
        id mappedElement = transform(element);
        if (mappedElement) {
            [mappedArray addObject:mappedElement];
        }
    }
    return [NSArray arrayWithArray:mappedArray];
}

@end
