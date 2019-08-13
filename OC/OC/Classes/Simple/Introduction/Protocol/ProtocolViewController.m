//
//  ProtocolViewController.m
//  OC
//
//  Created by yier on 2019/2/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "ProtocolViewController.h"
#import "Dog.h"

@interface ProtocolViewController ()<DogProtocol>

@end

@implementation ProtocolViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"Protocol";

}

- (void)initData{
    Dog * dog = [[Dog alloc]initWithProtocol:self];
    NSLog(@"%@",dog);
}

#pragma mark - setupUI

#pragma mark - initData
- (void)haveDog
{
    NSLog(@"haveDog");
}

-  (void)everyoneShouldEat{
    NSLog(@"everyoneShouldEat");
}

@end
