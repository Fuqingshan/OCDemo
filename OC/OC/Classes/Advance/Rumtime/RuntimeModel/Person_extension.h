//
//  Person_extension.h
//  RunTimeDEMO
//
//  Created by 尹文涛 on 16/4/13.
//  Copyright © 2016年 小木科技. All rights reserved.
//

//所谓延展，就是在.m里面添加的@interface ~ @end里面的属性,在@implementation里面实现了方法，都是私有的
#import "Person.h"

@interface Person ()

@property (nonatomic, copy) NSString *nickName;

@end
