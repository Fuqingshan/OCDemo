//
//  FacadeModeManager.m
//  OC
//
//  Created by yier on 2019/8/8.
//  Copyright © 2019 yier. All rights reserved.
//

#import "FacadeModeManager.h"
#import "FacadeMode1.h"
#import "FacadeMode2.h"

@implementation FacadeModeManager

- (void)facade1Test{
    FacadeMode1 *mode = [[FacadeMode1 alloc] init];
    [mode facadeTest];
}

- (void)facade2Test{
    FacadeMode2 *mode = [[FacadeMode2 alloc] init];
    [mode facadeTest];
}

@end
