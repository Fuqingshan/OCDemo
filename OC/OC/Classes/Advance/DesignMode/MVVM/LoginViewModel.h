//
//  LoginViewModel.h
//  OC
//
//  Created by yier on 2019/12/2.
//  Copyright © 2019 yier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginViewModel : NSObject
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) RACCommand *loginCommand;

@property (nonatomic, assign) BOOL loginBtnEnabled;

@end

