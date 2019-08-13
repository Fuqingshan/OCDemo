//
//  PageControlDefine.h
//  JMPageControl
//
//  Created by yier on 2018/2/22.
//  Copyright © 2018年 yier. All rights reserved.
//

#ifndef PageControlDefine_h
#define PageControlDefine_h

///这儿的左右指的是scrollView的滚动方向，而不是手势方向
typedef NS_ENUM(NSInteger,BannerScrollDirection){
    BannerScrollDirectionLeft,
    BannerScrollDirectionRight,
};

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define MaxCount (int)floor(ScreenWidth / CellWidth)

#define CellHeight 6.0f
#define CellWidth 16.0f
#define insetForSection UIEdgeInsetsMake(0, 0, 0, 0)
#define minimumLineSpacing 0.0f
#define minimumInteritemSpacing 0.0f

#endif /* PageControlDefine_h */
