//
//  Colors.h
//  App
//
//  Created by chenfei on 01/11/2016.
//  Copyright © 2016 yier. All rights reserved.
//

#ifndef Colors_h
#define Colors_h

#import "UIColor+Hex.h"

/*
 100%=FF（不透明）
 95%=F2
 90%=E5
 85%=D8
 80%=CC
 75%=BF
 70%=B2
 65%=A5
 60%=99
 55%=8C
 50%=7F
 45%=72
 40%=66
 35%=59
 30%=4C
 25%=3F
 20%=33
 15%=21
 10%=19
 05%=0C
 00%=00（全透明）
 
 格式：MCHexColor(0x4C000000)，前两个是alpha，和安卓保持一致，需要后两个表示alpha，用UIColor+YYAdd的扩展类
 */
#ifndef LKHexColor
#define LKHexColor(_hex_)   [UIColor lk_alphaColorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

#ifndef LKHexColorStr
#define LKHexColorStr(_hexStr_)   [UIColor lk_alphaColorWithHexString:_hexStr_]
#endif

#endif /* Colors_h */
