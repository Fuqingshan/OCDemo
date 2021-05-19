//
//  JImagePickerManager.m
//  JImagePicker
//
//  Created by yier on 15/9/11.
//  Copyright (c) 2015年 yier. All rights reserved.
//

#import "JImagePickerManager.h"
#import <objc/runtime.h>

#pragma mark - UIImagePicker catergory

static char kUIImagePickerSelectImageHandlerKey;
static char kUIImagePickerCancleHandlerKey;

typedef void(^ImagePickerControllerSelectImageHandler)(UIImage *image, NSDictionary *info);
typedef void(^ImagePickerControllerCancelBlock) (void);


@interface UIImagePickerController (ImagePicker)<
UIImagePickerControllerDelegate
,UINavigationControllerDelegate
>
@property (nonatomic ,copy)ImagePickerControllerSelectImageHandler selectImageHandler;
@property (nonatomic ,copy)ImagePickerControllerCancelBlock cancelBlock;
- (void)showWithModalViewController:(UIViewController *)modalViewController
                              animated:(BOOL)animated
                       selectedHandler:(ImagePickerControllerSelectImageHandler) slectedHandler
                                cancel:(ImagePickerControllerCancelBlock) cancelBlock;

@end

@implementation UIImagePickerController (ImagePicker)
@dynamic selectImageHandler;
@dynamic cancelBlock;

-(void)setSelectImageHandler:(ImagePickerControllerSelectImageHandler)selectImageHandler{
    objc_setAssociatedObject(self, &kUIImagePickerSelectImageHandlerKey, selectImageHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ImagePickerControllerSelectImageHandler)selectImageHandler{
    return  objc_getAssociatedObject(self, &kUIImagePickerSelectImageHandlerKey);
}

-(void)setCancelBlock:(ImagePickerControllerCancelBlock)cancelBlock{
    objc_setAssociatedObject(self, &kUIImagePickerCancleHandlerKey, cancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ImagePickerControllerCancelBlock)cancelBlock{
    return  objc_getAssociatedObject(self, &kUIImagePickerCancleHandlerKey);
}
-(void)showWithModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated selectedHandler:(ImagePickerControllerSelectImageHandler)slectedHandler cancel:(ImagePickerControllerCancelBlock)cancelBlock{
    
    self.delegate = self;
    self.selectImageHandler = slectedHandler;
    self.cancelBlock = cancelBlock;
    [modalViewController presentViewController:self animated:animated completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    UIImage *editedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
    if(!editedImage){
        editedImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
    }
    
    if (self.selectImageHandler) {
        self.selectImageHandler(editedImage,info);
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (picker.cancelBlock) {
        picker.cancelBlock();
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end

#pragma mark - UIImage Category
@interface UIImage (ResizeImage)
- (UIImage *)imageWithMaxSide:(CGFloat)length;
@end

@implementation UIImage (ResizeImage)
- (UIImage *)imageWithMaxSide:(CGFloat)length
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize imgSize = IMSizeReduce(self.size, length);
    UIImage *img = nil;
    
    // 创建一个 bitmap context
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, scale);
    // 将图片绘制到当前的 context 上
    [self drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)
           blendMode:kCGBlendModeNormal alpha:1.0];
    img = UIGraphicsGetImageFromCurrentImageContext();
    return img;
}

// 按比例减少尺寸
static inline
CGSize IMSizeReduce(CGSize size, CGFloat limit)
{
    CGFloat max = MAX(size.width, size.height);
    if (max < limit) {
        return size;
    }
    
    CGSize imgSize;
    CGFloat scale = size.height / size.width;
    
    if (size.width > size.height) {
        imgSize = CGSizeMake(limit, limit * scale);
    } else {
        imgSize = CGSizeMake(limit / scale, limit);
    }
    
    return imgSize;
}
@end

@interface JImagePickerManager()
@property (nonatomic ,copy)ImagePickerCompletion imagePickerCompletion;
@property (nonatomic ,weak)UIViewController * fromViewController;
@end

@implementation JImagePickerManager
+ (void)chooseImageFromViewController:(UIViewController*)viewController
                        allowEditting:(BOOL )editing
                   imageMaxSizeLength:(CGFloat)length
                     completionHandle:(ImagePickerCompletion)completionHandler{
    if (!viewController) {
        return;
    }
    //creat actionsheet
    UIAlertController * actionSheetVC = [UIAlertController alertControllerWithTitle:@"选择" message:@"从相册中选择或者拍一张二维码" preferredStyle:UIAlertControllerStyleActionSheet];
    
    @weakify(self);
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self showImagePickerControllerBySourceType:UIImagePickerControllerSourceTypePhotoLibrary
                                 fromViewController:viewController
                                      allowEditting:editing
                                 imageMaxSizeLength:length
                                   completionHandle:completionHandler];
    }];
    [actionSheetVC addAction:photoLibraryAction];
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            [self showImagePickerControllerBySourceType:UIImagePickerControllerSourceTypeCamera
                                     fromViewController:viewController
                                          allowEditting:editing
                                     imageMaxSizeLength:length
                                       completionHandle:completionHandler];
        }];
        [actionSheetVC addAction:cameraAction];
    }
    [viewController presentViewController:actionSheetVC animated:YES completion:nil];
}

+ (void)showImagePickerControllerBySourceType:(UIImagePickerControllerSourceType)sourceType
                           fromViewController:(UIViewController*)viewController
                                allowEditting:(BOOL )editing
                           imageMaxSizeLength:(CGFloat)length
                             completionHandle:(ImagePickerCompletion)completionHandler{
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    pickerController.allowsEditing = editing;
    pickerController.sourceType = sourceType;
    //下面两行设置无效，优先级还是appearance高
//    pickerController.navigationBar.tintColor = [UIColor orangeColor];
//    pickerController.navigationBar.barTintColor = [UIColor orangeColor];
    pickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [pickerController showWithModalViewController:viewController animated:YES selectedHandler:^(UIImage *image, NSDictionary *info) {
        //resize image
        UIImage *lastImage = nil;
        if (length > 0) {
            lastImage = [image imageWithMaxSide:length];
        } else {
            lastImage = image;
        }
        !completionHandler?:completionHandler(lastImage,info);
    } cancel:^{
        //cancle
        
    }];
}

@end

