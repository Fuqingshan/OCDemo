//
//  UnitTestPerson.h
//  Unit
//
//  Created by yier on 2020/2/23.
//  Copyright © 2020 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnitTestPerson : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) NSInteger age;

+ (instancetype)personWithDict:(NSDictionary *)dict;

@end

