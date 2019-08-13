//
//  Eunuch.m
//  OC
//
//  Created by yier on 2019/2/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "Eunuch.h"

@implementation Eunuch

@end

//@implementation Child
//
//@end

@implementation Father

- (void)eat{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)walk{
    NSLog(@"if you not override this method, you will get a exception");
    [self doesNotRecognizeSelector:_cmd];
}

@end

@implementation Son

- (void)eat{
    
}

@end

@implementation Sark

@end
