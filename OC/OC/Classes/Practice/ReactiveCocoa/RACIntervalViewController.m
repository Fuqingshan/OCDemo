//
//  RACIntervalViewController.m
//  OC
//
//  Created by yier on 2021/3/29.
//  Copyright © 2021 yier. All rights reserved.
//

#import "RACIntervalViewController.h"

@interface RACIntervalViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *syncTextField;

@property(nonatomic, assign) NSInteger second;

@end

@implementation RACIntervalViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    RACChannelTerminal *channel1 = self.codeTextField.rac_newTextChannel;
    RACChannelTerminal *channel2 = self.syncTextField.rac_newTextChannel;
    [channel1 subscribe:channel2];
    [channel2 subscribe:channel1];
    
    @weakify(self);
    [RACObserve(self, second) subscribeNext:^(NSNumber *second) {
        @strongify(self);
        NSAttributedString *attributedTitle = nil;
        if (second.integerValue == 0) {
            attributedTitle = [[NSAttributedString alloc] initWithString:@"发送验证码"
                                                              attributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor] }];
        } else {
            NSString *secondString = second.stringValue;
            NSString *titleString  = [NSString stringWithFormat:@"发送验证码(%@)", secondString];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleString];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:[titleString rangeOfString:@"发送验证码("]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[titleString rangeOfString:secondString]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:[titleString rangeOfString:@")"]];
            attributedTitle = attributedString.copy;
        }

        [self.loginBtn setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    }];
    
    self.loginBtn.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        @strongify(self);
        self.second = 5;
        return [[[[RACSignal
            interval:1
            onScheduler:[RACScheduler mainThreadScheduler]]
            take:5]
            doNext:^(id _) {
            @strongify(self);
                self.second--;
            }]
            takeUntil:self.rac_willDeallocSignal];
    }];
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
