//
//  VideoEditor.h
//  AVFoundationDemo
//
//  Created by yier on 2020/2/19.
//  Copyright © 2020 yier. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef void(^VideoEditCompletedBlock)(NSURL *url);
@interface VideoEditor : NSObject

+ (instancetype)shareInstance;

- (void)makeBirthdayCardFromVideoAt:(NSURL *)videoURL forName:(NSString *)name view:(UIView *)view completed:(VideoEditCompletedBlock)completedBlock;

@end

