//
//  AVFoundationVC24.m
//  AVFoundationDemo
//
//  Created by yier on 2020/2/18.
//  Copyright © 2020 yier. All rights reserved.
//
//使用AVVideoCompositionCoreAnimationTool添加叠加层overlays
#import "AVFoundationVC24.h"
#import "VideoEditor.h"

#import <Masonry/Masonry.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface AVFoundationVC24 ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(nonatomic, strong) UILabel *customLabel;
@property(nonatomic, strong) UITextField *nameTextField;
@property(nonatomic, strong) UIButton *recordButton;
@property(nonatomic, strong) UIButton *pickButton;

@end

@implementation AVFoundationVC24

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    
}

- (void)setupUI{
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
            
    self.customLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 200, 300, 100)];
    self.customLabel.text = @"Custom Birthday Cards";
    self.customLabel.textColor = [UIColor orangeColor];
    self.customLabel.textAlignment = 1;
    self.customLabel.font = [UIFont systemFontOfSize:25.0];
    [self.view addSubview:self.customLabel];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 300, 300, 50)];
    self.nameTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.nameTextField.layer.borderWidth = 1.0;
    [self.view addSubview:self.nameTextField];
    
    self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 500, 200, 30)];
    self.recordButton.backgroundColor = [UIColor blackColor];
    [self.recordButton setTitle:@"record a video" forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];

    self.pickButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 600, 200, 30)];
    self.pickButton.backgroundColor = [UIColor blackColor];
    [self.pickButton setTitle:@"pick video from photo" forState:UIControlStateNormal];
    [self.pickButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.pickButton addTarget:self action:@selector(pick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pickButton];
}

#pragma mark - Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.nameTextField canResignFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
}

- (void)record:(UIButton *)record{
    [self pickVideo:UIImagePickerControllerSourceTypeCamera];
}

- (void)pick:(UIButton *)pick{
    [self pickVideo:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (void)pickVideo:(UIImagePickerControllerSourceType)type{
    if (![UIImagePickerController isSourceTypeAvailable:type]) {
           return;
       }
   UIImagePickerController *picker = [[UIImagePickerController alloc] init];
   picker.allowsEditing = YES;
   picker.sourceType = type;
   picker.navigationBar.tintColor = [UIColor orangeColor];
   picker.mediaTypes = @[(__bridge NSString *)kUTTypeMovie];
   picker.delegate = self;

   [self presentViewController:picker animated:YES completion:^{
        
   }];
}

- (void)showVideo:(NSURL *)videoURL{
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
    vc.player = player;
    [self presentViewController:vc animated:YES completion:^{
        if ([vc isReadyForDisplay]) {
            [player play];
        }
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    NSURL *videoURL = (NSURL *)info[UIImagePickerControllerMediaURL];
    if(!videoURL){
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
 
    [picker dismissViewControllerAnimated:YES completion:^{
        [[VideoEditor shareInstance] makeBirthdayCardFromVideoAt:videoURL forName:self.nameTextField.text view:self.view completed:^(NSURL *url) {
            if (!url) {
                NSLog(@"播放地址为空");
                return ;
            }
            [self showVideo:url];
        }];
    }];

}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *title = !error?@"success":@"error";
    NSString *message = !error?@"save success":@"video failed to save";
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}



@end
