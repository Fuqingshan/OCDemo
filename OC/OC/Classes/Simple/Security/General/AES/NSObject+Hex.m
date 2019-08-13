//
//  NSObject+Hex.m
//  OC
//
//  Created by yier on 2019/3/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "NSObject+Hex.h"

@implementation NSObject (Hex)

+ (NSString *)Hex_DataToHexStringByData:(NSData *)data{
    NSUInteger len = [data length];
    char * chars = (char *)[data bytes];
    NSMutableString * hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    
    return hexString;
}

+ (NSData *)Hex_StringToHexDataByString:(NSString *)str{
    int len = (int)[str length] / 2; // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {};
    
    int i;
    for (i=0; i < [str length] / 2; i++) {
        byte_chars[0] = [str characterAtIndex:i*2];
        byte_chars[1] = [str characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}

@end
