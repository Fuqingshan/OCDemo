//
//  NSString+ThreeDES.h
//  3DE
//
//  Created by Brandon Zhu on 31/10/2012.
//  Copyright (c) 2012 Brandon Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ThreeDES)
+ (NSString*)DES_Encrypt:(NSString*)plainText withKey:(NSString*)key;
+ (NSString*)DES_Decrypt:(NSString*)encryptText withKey:(NSString*)key;
- (NSString*)sha1;
@end
