//
//  Runloop4ViewController.m
//  OC
//
//  Created by yier on 2019/4/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "Runloop4ViewController.h"
#import "CrashHandler.h"

@interface Runloop4ViewController ()

@end

@implementation Runloop4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CrashHandler sharedInstance];
    
    
}

- (IBAction)crashEVent:(id)sender {
    NSArray *array =[NSArray array];
    NSLog(@"%@",[array objectAtIndex:1]);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
