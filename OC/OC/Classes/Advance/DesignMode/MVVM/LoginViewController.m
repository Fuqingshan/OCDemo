//
//  LoginViewController.m
//  OC
//
//  Created by yier on 2019/12/2.
//  Copyright © 2019 yier. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "MBProgressHUD+LKAdditions.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) LoginViewModel *viewModel;

@end

@implementation LoginViewController


- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
    [self _test];
}

- (void)_test{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.viewModel.email = @"RACChannelTo@qq.com";
        self.viewModel.password = @"test channel";
    });
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"登录");
    self.logo.layer.cornerRadius = 48.0f;
    self.loginBtn.layer.cornerRadius = 8.0f;
    [self.loginBtn setTitle:LocalizedString(@"登录") forState:UIControlStateNormal];
        
    [self bindRAC];
    [self setupPlaceHolder];
}

- (void)bindRAC{
    RACChannelTo(self,viewModel.email) = self.mailTextField.rac_newTextChannel;
    RACChannelTo(self,viewModel.password) = self.passwordTextField.rac_newTextChannel;
    RAC(self,loginBtn.enabled) = [RACObserve(self,viewModel.loginBtnEnabled) distinctUntilChanged];
    
    @weakify(self);
    [[[self.tapGesture rac_gestureSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self);
        [self.view endEditing:NO];
    }];
    
    [[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
       @strongify(self);
        [MBProgressHUD lk_showRequestHUDWithMessage:@"请稍后" inView:self.view];
        [self.view endEditing:NO];
        [self.viewModel.loginCommand execute:@"老路老路"];
    }];
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
      merge:[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]]
      takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notify) {
        @strongify(self);
        [self adjustUIWithKeyboard:notify];
    }];
    
    [[[[self.viewModel.loginCommand executionSignals] switchToLatest] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [MBProgressHUD lk_dismiss];
        NSLog(@"success:%@",x);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)adjustUIWithKeyboard:(NSNotification *)notify{
    
    NSValue *value = notify.userInfo[@"UIKeyboardFrameEndUserInfoKey"];
    CGRect rect = value.CGRectValue;
    // Keyboard frame is always accordance to screen coordinates.
    // We should convert it within the `view's` own bounds before using it.
    rect = [self.view.window convertRect:rect toView:self.view];
    
    if ([notify.name isEqualToString:UIKeyboardWillShowNotification]) {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, rect.size.height, 0);
    }else if ([notify.name isEqualToString:UIKeyboardWillHideNotification]){
        self.scrollView.contentInset = UIEdgeInsetsZero;
    }
}

- (void)setupPlaceHolder{
    NSAttributedString *placeholder1 = [[NSAttributedString alloc] initWithString:LocalizedString(@"电子邮件") attributes:@{
                                                           NSFontAttributeName: PingFangSCRegular(14),
                                                NSForegroundColorAttributeName: LKHexColor(0xF3F3F3)}];
       NSAttributedString *placeholder2 = [[NSAttributedString alloc] initWithString:LocalizedString(@"登录密码") attributes:@{
                  NSFontAttributeName: PingFangSCRegular(14),
       NSForegroundColorAttributeName: LKHexColor(0xF3F3F3)}];
       self.mailTextField.attributedPlaceholder = placeholder1;
       self.passwordTextField.attributedPlaceholder = placeholder2;
}

- (void)initData{

}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"登录");
}

#pragma mark - initData

#pragma mark - lazy load
- (LoginViewModel *)viewModel{
    if(!_viewModel){
        _viewModel = [LoginViewModel new];
    }
    return _viewModel;
}

@end
