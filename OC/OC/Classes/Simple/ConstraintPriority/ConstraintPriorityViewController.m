//
//  ConstraintPriorityViewController.m
//  OC
//
//  Created by yier on 2019/4/6.
//  Copyright © 2019 yier. All rights reserved.
//

#import "ConstraintPriorityViewController.h"

@interface ConstraintPriorityViewController ()
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceTrailingC;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation ConstraintPriorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RAC(self, firstLabel.text) = self.textField.rac_textSignal;
    @weakify(self);
    RAC(self,firstLabel.hidden) = [self.textField.rac_textSignal filter:^BOOL(NSString * value) {
        @strongify(self);
        //第一个Label的右边有两个约束优先级，一个是800时间距0，一个默认是999的间距15，这儿设置内容空时999优先级变低，800优先级生效的情况
        self.distanceTrailingC.priority = value.length == 0?751:999;
        return value.length == 0;
    }];
    
    [[[self.textField rac_textSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        NSLog(@"textFiled:%@",x);
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
