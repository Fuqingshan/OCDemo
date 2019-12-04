//
//  LoginViewModel.m
//  OC
//
//  Created by yier on 2019/12/2.
//  Copyright © 2019 yier. All rights reserved.
//

#import "LoginViewModel.h"

@implementation LoginViewModel

- (void)dealloc{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self bindViewModel];
    }
    return self;
}

- (void)bindViewModel{
    //提示加内容校验
    RACSignal *emailSignal = [RACObserve(self, email) takeUntil:self.rac_willDeallocSignal];
    //密码校验
    RACSignal *passwordSignal = [RACObserve(self, password) takeUntil:self.rac_willDeallocSignal];
    
    @weakify(self);
    [[RACSignal combineLatest:@[emailSignal, passwordSignal] reduce:^id (NSString *email, NSString *password){
        @strongify(self);
        if (email.length < 6 || password.length < 6) {
            return @NO;
        }
        
        if (![self checkEmail:email]) {
            return @NO;
        }
        
        return @YES;
    }] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        self.loginBtnEnabled = x.boolValue;
    }];
    
    self.loginCommand =  [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        return [self requestSignal];
    }];
}

- (RACSignal *)requestSignal{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@{@"code":@"0"}];
            [subscriber sendCompleted];
        });
        
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
}

- (BOOL)checkEmail:(NSString *)email{
    NSString *pattern = @"^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$";
    NSArray<NSTextCheckingResult *> *matches = [[[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil] matchesInString:email options:kNilOptions range:NSMakeRange(0, email.length)];
    
    return matches.count > 0;
}

@end
