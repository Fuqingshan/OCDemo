//
//  CIFilter+ColorLUT.h
//  OC
//
//  Created by yier on 2021/4/14.
//  Copyright © 2021 yier. All rights reserved.
//
//http://huangtw-blog.logdown.com/posts/176980-ios-quickly-made-using-a-cicolorcube-filter
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIFilter (ColorLUT)

/*LUT其实是一张颜色映射表，执行滤镜算法的时候，此算法会对Image的每个像素执行颜色映射（根据Image的R，G，B，A在LUT上进行颜色查找），这样就能对整个图像的色调进行改变，达到滤镜的效果。
imageName 颜色查找表的图片
 dimension这个数字意味着颜色查找表正立方体一条边上的晶格点（Lattice）的数量，数量越接近255越精确（64对标255的情况下，没有的格子就靠猜），但计算量也越大，比方说一个64x64x64 的3D LUT 只比32x32x32 的3D LUT 精度上提高了一倍，但是计算量却是增加了8 倍。
 */
+ (CIFilter *)colorCubeWithColrLUTImageNamed:(NSString *)imageName dimension:(NSInteger)n;


/// 直接把原图用映射表转换成新图
/// @param originImage 原图
/// @param lutImage 颜色查找表的图片
/// @param n 有多少个小方格
+ (UIImage *)transformImageByOriginImage:(UIImage *)originImage lutImageNamed:(NSString *)lutImage dimension:(NSInteger)n;

@end

NS_ASSUME_NONNULL_END
