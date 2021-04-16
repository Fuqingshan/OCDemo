//
//  Runloop4ViewController.m
//  OC
//
//  Created by yier on 2019/4/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "Runloop4ViewController.h"
#import "LKCrashMonitor.h"
#import "MBProgressHUD+LKAdditions.h"

@interface Runloop4ViewController ()

@end

@implementation Runloop4ViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LKCrashMonitor registerExceptionHandler];

    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:LKAppOnException object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"程序崩溃了"
                                                        message:@"如果你能让程序起死回生，那你的决定是？"
                                                       delegate:nil
                                              cancelButtonTitle:@"崩就蹦吧"
                                              otherButtonTitles:@"起死回生", nil];
        [alert show];
        
        [LKCrashMonitor crashAfterDelay:5];
    }];
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
