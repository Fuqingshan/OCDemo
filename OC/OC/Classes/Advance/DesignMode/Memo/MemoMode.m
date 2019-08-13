//
//  MemoMode.m
//  OC
//
//  Created by yier on 2019/8/8.
//  Copyright © 2019 yier. All rights reserved.
//

#import "MemoMode.h"

@implementation MemoMode

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:nilToEmptyString(self.name) forKey:@"name"];
    [aCoder encodeInteger:self.age forKey:@"age"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.age = [aDecoder decodeIntegerForKey:@"age"];
    }
    
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"student name is %@, age is %zd",self.name,self.age];
}


@end
