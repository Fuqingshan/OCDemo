//
//  TwitterViewController.m
//  OCMockTest
//
//  Created by yier on 2020/2/26.
//  Copyright © 2020 yier. All rights reserved.
//

#import "TwitterViewController.h"

@interface TwitterViewController ()

@end

@implementation TwitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)updateTwitterView{
    NSArray *twitters = [_connection fetchTwitters];
    if (twitters) {
        for (Twitter *t in twitters) {
            [_twitterView addTweet:t];
        }
    }
}

- (void)updateTwitterView2{
    NSArray *twitters = [TwitterConnection fetchTwitters2];
      if (twitters) {
          for (Twitter *t in twitters) {
              [_twitterView addTweet:t];
          }
      }
}

@end
