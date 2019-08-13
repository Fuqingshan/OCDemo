//
//  JImagePickerManager.h
//  JImagePicker
//
//  Created by yier on 15/9/11.
//  Copyright (c) 2015年 yier. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef void (^ImagePickerCompletion) (UIImage *  image,  NSDictionary *  pickingMediainfo);

@interface JImagePickerManager : NSObject

+ (void)chooseImageFromViewController:(UIViewController*)viewController
                        allowEditting:(BOOL )editing
                   imageMaxSizeLength:(CGFloat)lenght
                     completionHandle:(ImagePickerCompletion)completionHandler;

@end
