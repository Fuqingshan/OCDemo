//
//  Student.h
//  runtime
//
//  Created by yier on 16/4/15.
//  Copyright © 2016年 newdoone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RuntimeBaseModel.h"

@interface Student : RuntimeBaseModel

@property(nonatomic, assign) int age;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, assign)float height;

@end
