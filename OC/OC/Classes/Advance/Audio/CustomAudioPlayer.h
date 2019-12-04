//
//  CustomAudioPlayer.h
//  OC
//
//  Created by yier on 2019/8/12.
//  Copyright © 2019 yier. All rights reserved.
//

#define kEQChangedNotificationName @"kEQChangedNotificationName"
#define kEQBandKeyPrefix @"EQBand"
#define kEQBandCount (10)

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CustomAudioPlayer : NSObject
@property (nonatomic, strong) NSMutableData *pcmData;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, weak) id<AVAudioPlayerDelegate> delegate;

- (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError **)outError;
- (void)play;
- (void)pause;
- (void)stop;

@end
