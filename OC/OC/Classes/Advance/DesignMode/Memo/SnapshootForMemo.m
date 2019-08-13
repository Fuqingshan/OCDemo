//
//  SnapshootForMemo.m
//  OC
//
//  Created by yier on 2019/8/8.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SnapshootForMemo.h"

@implementation SnapshootForMemo

+ (NSString *)memoPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDir = paths.firstObject;
    NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"archives"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:logsDirectory]) {
        BOOL create =  [[NSFileManager defaultManager] createDirectoryAtPath:logsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (!create) {
            return nil;
        }
    }
    
    NSString *archivePath = [logsDirectory stringByAppendingPathComponent: @"memo"];
    return  archivePath;
}

+ (void)save:(MemoMode *)mode{
    NSString *path = [self memoPath];
    if (![path isValide]) {
        return;
    }
    
    BOOL result = [NSKeyedArchiver archiveRootObject:mode toFile:path];
    if (result) {
        NSLog(@"归档成功");
    }
}

+ (MemoMode *)read{
    NSString *path = [self memoPath];
    if (![path isValide]) {
        return nil;
    }
    
    MemoMode *mode = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
 
    return mode;
}


@end
