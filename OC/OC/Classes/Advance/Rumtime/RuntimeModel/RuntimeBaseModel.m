//
//  RuntimeBaseModel.m
//  runtime
//
//  Created by yier on 16/6/20.
//  Copyright © 2016年 newdoone. All rights reserved.
//

#import "RuntimeBaseModel.h"
#import <objc/runtime.h>

@interface RuntimeBaseModel()<NSCoding>

@end

@implementation RuntimeBaseModel

//注意：归档解档需要遵守<NSCoding>协议，实现以下两个方法
- (void)encodeWithCoder:(NSCoder *)encoder{
    //归档存储自定义对象
    unsigned int count = 0;
    //获得指向该类所有属性的指针
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i =0; i < count; i ++) {
        //获得
        objc_property_t property = properties[i];
        //根据objc_property_t获得其属性的名称--->C语言的字符串
        const char *name = property_getName(property);
        NSString *key = [NSString stringWithUTF8String:name];
        // 编码每个属性,利用kVC取出每个属性对应的数值
        [encoder encodeObject:[self valueForKeyPath:key] forKey:key];
    }
}

- (instancetype)initWithCoder:(NSCoder *)decoder{
    //归档存储自定义对象
    unsigned int count = 0;
    //获得指向该类所有属性的指针
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i =0; i < count; i ++) {
        objc_property_t property = properties[i];
        //根据objc_property_t获得其属性的名称--->C语言的字符串
        const char *name = property_getName(property);
        NSString *key = [NSString stringWithUTF8String:name];
        //解码每个属性,利用kVC取出每个属性对应的数值
        [self setValue:[decoder decodeObjectForKey:key] forKeyPath:key];
    }
    return self;
}

-(id)description{
    NSMutableDictionary * propertyDescription = @{}.mutableCopy;
    unsigned int count = 0;
    //获得指向该类所有属性的指针
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i =0; i < count; i ++) {
        //获得
        objc_property_t property = properties[i];
        //根据objc_property_t获得其属性的名称--->C语言的字符串
        const char *name = property_getName(property);
        NSString *key = [NSString stringWithUTF8String:name];
        // 编码每个属性,利用kVC取出每个属性对应的数值
        [propertyDescription setObject:[self valueForKeyPath:key] == nil?@"":[self valueForKeyPath:key] forKey:key];
    }
    NSData * descriptionData;
    @try {
        descriptionData = [NSJSONSerialization dataWithJSONObject:propertyDescription options:NSJSONWritingPrettyPrinted error:nil];

    } @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
        
    } @finally {
        if (!descriptionData) {
            NSLog(@"%@",[self toDictionary]);
            UIAlertAction * actionCancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[OCRouter shareInstance].selectedViewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
                }];
            }];
            UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"%@",[self toDictionary]] preferredStyle:UIAlertControllerStyleAlert];
            [alertC addAction:actionCancle];
            [[OCRouter shareInstance].selectedViewController presentViewController:alertC animated:YES completion:^{
                
            }];
        }
        return !descriptionData ?@"":[[NSString alloc] initWithData:descriptionData encoding:NSUTF8StringEncoding];
    }
    
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary * propertyDescription = @{}.mutableCopy;
    unsigned int count = 0;
    //获得指向该类所有属性的指针
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i =0; i < count; i ++) {
        //获得
        objc_property_t property = properties[i];
        //根据objc_property_t获得其属性的名称--->C语言的字符串
        const char *name = property_getName(property);
        NSString *key = [NSString stringWithUTF8String:name];
        // 编码每个属性,利用kVC取出每个属性对应的数值
        [propertyDescription setObject:[self valueForKeyPath:key] == nil ? @"" :[self valueForKeyPath:key] forKey:key];
    }
    
    return propertyDescription == nil ? @{} :propertyDescription;
}

- (void)saveModel
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archiver",NSStringFromClass([self class])]];
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

+ (id)getModel
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archiver",NSStringFromClass([self class])]];
    
    return ![[NSFileManager defaultManager] fileExistsAtPath:path] ? nil : [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

+ (void)clearModel
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archiver",NSStringFromClass([self class])]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    }
}

@end
