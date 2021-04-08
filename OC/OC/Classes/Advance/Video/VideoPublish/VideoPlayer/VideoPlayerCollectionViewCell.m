//
//  VideoPlayerCollectionViewCell.m
//  OC
//
//  Created by yier on 2021/4/8.
//  Copyright © 2021 yier. All rights reserved.
//

#import "VideoPlayerCollectionViewCell.h"
#import "VideoPlayerModel.h"

@interface VideoPlayerCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *videoThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property(nonatomic, strong) VideoPlayerModel *model;

@end

@implementation VideoPlayerCollectionViewCell

- (void)dealloc{
    
}

+ (CGFloat)cellHeight{
    return 0.0f;
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
    self.videoThumbnailImageView.tag = kPlayerViewTag;
    self.videoThumbnailImageView.userInteractionEnabled = YES;
    self.videoThumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;

}

- (void)fillCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if ([model isKindOfClass:[VideoPlayerModel class]]) {
        self.model = model;
        [self.videoThumbnailImageView sd_setImageWithURL:self.model.thumbnailURL];
        self.contentLabel.text = self.model.content;
    }
}

@end
