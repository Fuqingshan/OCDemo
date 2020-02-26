//
//  CapturePreview.h
//  OC
//
//  Created by yier on 2020/2/26.
//  Copyright © 2020 yier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CapturePreview : UIView
@property(nonatomic, strong) NSData *image;
@property(nonatomic, strong) UIImage *ciImage;
@property(nonatomic, strong) UIImageView *imageView;

@end

