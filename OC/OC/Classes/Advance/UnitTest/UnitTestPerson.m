//
//  UnitTestPerson.m
//  Unit
//
//  Created by yier on 2020/2/23.
//  Copyright © 2020 yier. All rights reserved.
//

#import "UnitTestPerson.h"

@implementation UnitTestPerson

+ (instancetype)personWithDict:(NSDictionary *)dict {
    UnitTestPerson *obj = [[self alloc] init];
    [obj setValuesForKeysWithDictionary:dict];
    
    if (obj.age <= 0 || obj.age >= 130) {
        obj.age = 0;
    }
    
    return obj;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"key is %@ ,value is %@ 不处理",key, value);
}

@end
