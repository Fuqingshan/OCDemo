//
//  CIFilter+ColorLUT.m
//  OC
//
//  Created by yier on 2021/4/14.
//  Copyright © 2021 yier. All rights reserved.
//

#import "CIFilter+ColorLUT.h"

@implementation CIFilter (ColorLUT)

+ (CIFilter *)colorCubeWithColrLUTImageNamed:(NSString *)imageName dimension:(NSInteger)n{
    UIImage *image = [UIImage imageNamed:imageName];

    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    size_t rowNum = height / n;
    size_t columnNum = width / n;

    if ((width % n != 0) || (height % n != 0) || (rowNum * columnNum != n)){
        NSLog(@"Invalid colorLUT");
        return nil;
    }

    unsigned char *bitmap = [self createRGBABitmapFromImage:image.CGImage];
    
    if (bitmap == NULL)
    {
        return nil;
    }

    size_t size = n * n * n * sizeof(float) * 4;
    float *data = malloc(size);
    int bitmapOffest = 0;
    int z = 0;
    for (int row = 0; row <  rowNum; row++)
    {
        for (int y = 0; y < n; y++)
        {
            int tmp = z;
            for (int col = 0; col < columnNum; col++)
            {
                for (int x = 0; x < n; x++) {
                    float r = (unsigned int)bitmap[bitmapOffest];
                    float g = (unsigned int)bitmap[bitmapOffest + 1];
                    float b = (unsigned int)bitmap[bitmapOffest + 2];
                    float a = (unsigned int)bitmap[bitmapOffest + 3];
                    
                    size_t dataOffset = (z*n*n + y*n + x) * 4;

                    data[dataOffset] = r / 255.0;
                    data[dataOffset + 1] = g / 255.0;
                    data[dataOffset + 2] = b / 255.0;
                    data[dataOffset + 3] = a / 255.0;

                    bitmapOffest += 4;
                }
                z++;
            }
            z = tmp;
        }
        z += columnNum;
    }

    free(bitmap);
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorCube"];
    [filter setValue:[NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES] forKey:@"inputCubeData"];
    [filter setValue:[NSNumber numberWithInteger:n] forKey:@"inputCubeDimension"];

    return filter;
}

+ (unsigned char *)createRGBABitmapFromImage:(CGImageRef)image{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    unsigned char *bitmap;
    size_t bitmapSize;
    size_t bytesPerRow;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    bytesPerRow   = (width * 4);
    bitmapSize     = (bytesPerRow * height);
    
    bitmap = malloc( bitmapSize );
    if (bitmap == NULL)
    {
        return NULL;
    }
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        free(bitmap);
        return NULL;
    }
    
    context = CGBitmapContextCreate (bitmap,
                                     width,
                                     height,
                                     8,
                                     bytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease( colorSpace );
    
    if (context == NULL)
    {
        free (bitmap);
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    CGContextRelease(context);
    
    return bitmap;
}


+ (UIImage *)transformImageByOriginImage:(UIImage *)originImage lutImageNamed:(NSString *)lutImage dimension:(NSInteger)n{
    CIFilter *colorCube = [CIFilter colorCubeWithColrLUTImageNamed:lutImage dimension:n];
    CIImage *inputImage = [[CIImage alloc] initWithImage: originImage];
    [colorCube setValue:inputImage forKey:kCIInputImageKey];
    CIImage *outputImage = [colorCube outputImage];
    if (!outputImage) {
        return nil;
    }
    
    CIContext *context = [CIContext contextWithOptions:@{
        kCIContextWorkingColorSpace : (__bridge_transfer id)CGColorSpaceCreateDeviceRGB()//把CGColorSpace释放交给ARC
    }];
    CGImageRef newImageRef = [context createCGImage:outputImage fromRect:outputImage.extent];
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);

    return newImage;
}

@end
