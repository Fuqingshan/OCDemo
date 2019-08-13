//
//  Eunuch.h
//  OC
//
//  Created by yier on 2019/2/19.
//  Copyright © 2019 yier. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//Eunuch:太监
//不允许继承
__attribute__((objc_subclassing_restricted))
@interface Eunuch : NSObject

@end

//@interface Child: Eunuch
//
//@end

@interface Father: NSObject
//子类调用时必须调用父类
- (void)eat __attribute__((objc_requires_super));

- (void)walk;//子类都要重写这个方法，否则调用时会抛异常，当然也可以用Protocol实现

/*
 重载（overload）：函数名相同,函数的参数列表不同(包括参数个数和参数类型)，至于返回类型可同可不同。重载既可以发生在同一个类的不同函数之间，也可发生在父类子类的继承关系之间，其中发生在父类子类之间时要注意与重写区分开。
 重写（override）：发生于父类和子类之间，指的是子类不想继承使用父类的方法，通过重写同一个函数的实现实现对父类中同一个函数的覆盖，因此又叫函数覆盖。注意重写的函数必须和父类一模一样，包括函数名、参数个数和类型以及返回值，只是重写了函数的实现，这也是和重载区分开的关键。
 swift支持重载，OC支持参数个数不同的函数重载。
 */

@end

@interface Son : Father

@end

__attribute__((objc_runtime_name("40ea43d7629d01e4b8d6289a132482d0dd5df4fa")))
@interface Sark : NSObject
@end

NS_ASSUME_NONNULL_END
