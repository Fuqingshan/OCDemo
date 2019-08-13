//
//  Dog.h
//  TestProtocol
//
//  Created by yier on 16/3/31.
//  Copyright © 2016年 newdoone. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DogProtocol <NSObject>
/**
 *  以下是常规需要实现的
 */
- (void)haveDog;

/**
 *  可选的，不是必须实现的
 */
@optional
- (void)palyWithDog;

/**
 *   必须的方法标志，以下都是必须的方法
 */
@required
-  (void)everyoneShouldEat;
@end

@interface Dog : NSObject
{
    NSString * master;
    @private//自身可以访问
    NSString * name;
    @protected //自身和子类可以访问
    NSInteger age;
}
@property (nonatomic, weak)  id<DogProtocol> delegate;

- (instancetype)initWithProtocol:(id<DogProtocol>)protocol;

@end
