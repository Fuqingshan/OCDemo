//
//  Dog.m
//  TestProtocol
//
//  Created by yier on 16/3/31.
//  Copyright © 2016年 newdoone. All rights reserved.
//

#import "Dog.h"

@implementation Dog

- (instancetype)initWithProtocol:(id<DogProtocol>)protocol
{
    self = [super init];
    if (self) {
        if (protocol) {
            self.delegate = protocol;
            [self protocolRealize];
        }
    }
    
    return self;
}

- (void)protocolRealize{
    if ([self.delegate respondsToSelector:@selector(haveDog)]) {
        [self.delegate haveDog];
    }
    
    if ([self.delegate respondsToSelector:@selector(everyoneShouldEat)]) {
        [self.delegate everyoneShouldEat];
    }

}

@end
