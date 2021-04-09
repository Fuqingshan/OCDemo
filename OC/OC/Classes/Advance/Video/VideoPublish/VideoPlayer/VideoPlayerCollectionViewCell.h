//
//  VideoPlayerCollectionViewCell.h
//  OC
//
//  Created by yier on 2021/4/8.
//  Copyright © 2021 yier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCFillCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayerCollectionViewCell : UICollectionViewCell<OCFillCellProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *videoThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playView;

@end

NS_ASSUME_NONNULL_END
