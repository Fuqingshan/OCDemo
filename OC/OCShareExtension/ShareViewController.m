//
//  ShareViewController.m
//  OCShareExtension
//
//  Created by yier on 2021/6/2.
//  Copyright © 2021 yier. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    [self openContainerApp];
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

/// 打开主APP的短视频页面
- (void)openContainerApp {
    NSString *scheme = @"sumup://advance/video/videoplayer";
    NSURL *url = [[NSURL alloc] initWithString:scheme];
    NSExtensionContext *context = [[NSExtensionContext alloc] init];
    [context openURL:url completionHandler:nil];
    UIResponder *responder = (UIResponder *)self;
    SEL selectorOpenURL = sel_registerName("openURL:");
    while (responder != nil) {
        if ([responder respondsToSelector:selectorOpenURL]) {
            [responder performSelector:selectorOpenURL withObject:url];
            break;
        }
        responder = responder.nextResponder;
    }
}

@end
