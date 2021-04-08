//
//  TwitterViewController.h
//  OCMockTest
//
//  Created by yier on 2020/2/26.
//  Copyright © 2020 yier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterConnection.h"
#import "TwitterView.h"

@interface TwitterViewController : UIViewController
@property(nonatomic, strong) TwitterConnection *connection;
@property(nonatomic, strong) TwitterView *twitterView;

- (void)updateTwitterView;

- (void)updateTwitterView2;

@end

