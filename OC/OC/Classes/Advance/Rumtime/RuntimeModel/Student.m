//
//  Student.m
//  runtime
//
//  Created by yier on 16/4/15.
//  Copyright © 2016年 newdoone. All rights reserved.
//

#import "Student.h"
#import <objc/runtime.h>


@implementation Student

#pragma mark 写入文件
//-(void)encodeWithCoder:(NSCoder *)encoder{
//    [encoder encodeInt:self.age forKey:@"age"];
//    [encoder encodeObject:self.name forKey:@"name"];
//    [encoder encodeFloat:self.height forKey:@"height"];
//}
//
//#pragma mark 从文件中读取
//-(id)initWithCoder:(NSCoder *)decoder{
//    self.age = [decoder decodeIntForKey:@"age"];
//    self.name = [decoder decodeObjectForKey:@"name"];
//    self.height = [decoder decodeFloatForKey:@"height"];
//    
//    return self;
//}
//
//
//-(NSString *)description{
//    return [NSString stringWithFormat:@"name = %@, age = %d, height = %f",self.name,self.age,self.height];
//}

void functionForMethod1(id self, SEL _cmd) {
    NSLog(@"%@, %s", self, sel_getName(_cmd));
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    NSString *selectorString = NSStringFromSelector(sel);
    
    if ([selectorString isEqualToString:@"autoAddMethod"]) {
        class_addMethod(self.class, sel_registerName("autoAddMethod"), (IMP)functionForMethod1, "@:");
    }
    
    return [super resolveInstanceMethod:sel];
}


@end
