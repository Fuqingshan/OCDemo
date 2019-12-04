//
//  OCRouter+Advance.m
//  App
//
//  Created by yier on 2019/1/22.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouter+Advance.h"
#import "OCRouter+Common.h"
#import "NSString+URLQuery.h"

@implementation OCRouter (Advance)

#pragma mark -  处理Advance相关的router
+ (BOOL)openAdvanceURL:(NSURL *)url{
    if (![[url host] isEqualToString:@"advance"]) {
        return NO;
    }
    if ([[url path] isEqualToString:@""]) {
        [self showAdvanceViewController];
    }
    //runtime
    else if([[url path] isEqualToString:@"/runtime"]) {
        [self showViewControllerByIdentifier:@"RuntimeVC" storyboardName:@"Runtime"];
    }
    //runloop
    else if([[url path] isEqualToString:@"/runloop"]) {
        [self showViewControllerByIdentifier:@"RunloopVC" storyboardName:@"Runloop"];
    }else if([[url path] isEqualToString:@"/runloop/runloop1"]) {
        [self showViewControllerByIdentifier:@"Runloop1VC" storyboardName:@"Runloop"];
    }else if([[url path] isEqualToString:@"/runloop/runloop2"]) {
        [self showViewControllerByIdentifier:@"Runloop2VC" storyboardName:@"Runloop"];
    }else if([[url path] isEqualToString:@"/runloop/runloop3"]) {
        [self showViewControllerByIdentifier:@"Runloop3VC" storyboardName:@"Runloop"];
    }else if([[url path] isEqualToString:@"/runloop/runloop4"]) {
        [self showViewControllerByIdentifier:@"Runloop4VC" storyboardName:@"Runloop"];
    }
    //DesignMode
    else if([[url path] isEqualToString:@"/designmode"]) {
        [self showViewControllerByIdentifier:@"DesignModeVC" storyboardName:@"DesignMode"];
    }else if([[url path] isEqualToString:@"/designmode/login"]) {
        [self showViewControllerByIdentifier:@"LoginVC" storyboardName:@"Login"];
    }
    //Audio
    else if([[url path] isEqualToString:@"/audio"]) {
        [self showViewControllerByIdentifier:@"AudioVC" storyboardName:@"Audio"];
    }
    //Video
    else if([[url path] isEqualToString:@"/video"]) {
        [self showViewControllerByIdentifier:@"VideoVC" storyboardName:@"Video"];
    }
    else{
        return NO;
    }
    
    return YES;
}

#pragma mark -  展示Advance
+ (void)showAdvanceViewController{
    [OCRouter shareInstance].rootViewController.tabbarVC.itemType = TabBarItemTypeAdvance;
}

@end
