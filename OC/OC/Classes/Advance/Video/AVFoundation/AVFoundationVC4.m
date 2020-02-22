//
//  AVFoundationVC4.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/9.
//  Copyright © 2020 yier. All rights reserved.
//

#import "AVFoundationVC4.h"
#import <AVFoundation/AVFoundation.h>

@interface AVFoundationVC4 ()

@end

@implementation AVFoundationVC4

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    [self test];
    // Do any additional setup after loading the view.
}

#pragma mark - test
- (void)test{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"AVFoundation_hourse" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:url];
    //异步的加载一个或者多个属性值，你传递给一个键组成的数组，它们是要加载的属性的名字，和在确定状态之后调用的完成块。 以下示例显示如何异步加载资产的可播放属性。
    NSString *key = @"playable";
    //此属性返回其包含的每个元数据格式的字符串标识符数组
    NSString *availableMetadataFormats = @"availableMetadataFormats";
    
    //获取common metadata 中的title
    NSArray<AVMetadataItem *>  *commonDatas = asset.commonMetadata;
    NSArray<AVMetadataItem *> *title = [AVMetadataItem metadataItemsFromArray:commonDatas filteredByIdentifier:AVMetadataCommonIdentifierTitle];
    NSArray<AVMetadataItem *> *arts = [AVMetadataItem metadataItemsFromArray:commonDatas filteredByIdentifier:AVMetadataCommonIdentifierArtwork];
    //获取艺术图片
    UIImage *img = [UIImage imageWithData:arts.firstObject.dataValue];
    
    [asset loadValuesAsynchronouslyForKeys:@[key,availableMetadataFormats] completionHandler:^{
        NSError *error;
        AVKeyValueStatus status1 = [asset statusOfValueForKey:key error:&error];
        
        switch (status1) {
            case AVKeyValueStatusLoaded:
                //handle load success,continue processing
                dispatch_async(dispatch_get_main_queue(), ^{
                   //handle UI
                });
                break;
            case AVKeyValueStatusFailed:
                //handle error
                break;
            case AVKeyValueStatusCancelled:
                //handle cancle
                break;
                
            default:
                //handle all other case
                break;
        }
        
        AVKeyValueStatus status2 = [asset statusOfValueForKey:availableMetadataFormats error:&error];
        if (status2 == AVKeyValueStatusLoaded) {
            for (AVMetadataFormat format in asset.availableMetadataFormats) {
                NSArray<AVMetadataItem *> *items = [asset metadataForFormat:format];
                
            }
        }
        
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
