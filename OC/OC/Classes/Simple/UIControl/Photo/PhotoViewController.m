//
//  PhotoViewController.m
//  OC
//
//  Created by yier on 2019/3/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "PhotoViewController.h"
#import <CKYPhotoBrowser/KYPhotoBrowserController.h>
#import <objc/message.h>

@import Photos;

@interface PhotoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation PhotoViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"照片资源";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"photoKit层级"
                            ,@"sel":@"PhotoKitHierarchySelector"
                            }
                        ,@{
                            @"content":@"photoKit使用"
                            ,@"sel":@"PhotoKitSelector"
                            }
                        ].mutableCopy;
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *content = stringInDictionaryForKey(dic, @"content");
    cell.textLabel.text = [NSString stringWithFormat:@"%@",content];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *selStr = stringInDictionaryForKey(dic, @"sel");
    NSString *url = stringInDictionaryForKey(dic, @"url");
    if ([url isValide]) {
        [OCRouter openURL:[NSURL URLWithString:url]];
        return;
    }
    SEL sel = NSSelectorFromString(selStr);
    @try {
        ((void(*)(id,SEL))objc_msgSend)(self,sel);
        //有返回值
        //    ((NSString *(*)(id,SEL))objc_msgSend)(self,sel);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    } @finally {
        
    }
}

- (void)PhotoKitHierarchySelector{
    [KYPhotoBrowserController showPhotoBrowserWithImages:@[[UIImage imageNamed:@"PhotoKit.png"]] currentImageIndex:0 delegate:nil];
}

/**
 info.plist增加Privacy - Photo Library Usage Description 
 
 · PHAssetCollection:照片资源的集合类，可以表示一个相册，一个时刻等等
 · PHCollectionList：表示一个资源集合的集合，比如一个相册，相册中又有其他的相册集
 · PHFetchResult：一系列资源的结果集合，也可以是相册的集合，从PHCollection的子类的类方法中获得（如fetchAssetCollectionsWithType:options:），这个对象包含很多个PHAsset
 · PHFetchOptions:获取资源结果时，所传的参数，具体参数可以查看文档
 · PHAsset 表示用户照片库中一个单独的资源，用以提供资源的元数据,是PHImageManager直接处理的对象
 · PHImageManager：通过将图片资源加载处理输出图片的类
 · PHImageRequestOptions:对资源数据进行处理的一些请求参数，比如图片大小，质量高低等

 */
- (void)PhotoKitSelector
{
    @weakify(self);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        @strongify(self);
        /*
         当status等于PHAuthorizationStatusAuthorized表示用户已经授予了权限。
         该方法在应用初次询问时，会直接弹出系统的权限询问，
         用户操作后才会回调，所以不存在PHAuthorizationStatusNotDetermined
         （用户还未对权限进行选择）的状态。
         PHAuthorizationStatusRestricted,这种是当前用户无权限访问，比如开启了父母控制模式，登录的用户是孩子
         */
        switch (status) {
            case PHAuthorizationStatusNotDetermined:
                NSLog(@"权限弹窗出来了，用户还未决定，这儿不会出现");
                break;
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:
            {
                NSLog(@"访问被拒 --- status：%zd   thread：%@",status,[NSThread currentThread]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showDeniedAlert];
                });
            }
                break;
            case PHAuthorizationStatusAuthorized:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self PhotoKitUseSelector];
                });
            }
                break;
        }
    }];
}

- (void)showDeniedAlert{
    NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSLog(@"%@",mainInfoDictionary);
    NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleName"];
    NSString *msg = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    [alertC addAction:alertAction];
    [self presentViewController:alertC animated:YES completion:^{
        
    }];
}

- (void)PhotoKitUseSelector{
    CGSize SomeSize = CGSizeMake(300, 300);
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //按照估计的每个相册的照片数排序
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"estimatedAssetCount" ascending:NO];
    PHFetchOptions * fetchOptions= [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[sort];
    //根据类型（PHAssetCollectionTypeAlbum ）获取照片库中所有的用户创建的相册，返回结果是PHFetchResult，里面是所有的相册列表
    PHFetchResult * alist_album = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
    
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    // 在资源的集合中获取第一个集合，并获取其中的图片
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

    NSMutableArray *arr = @[].mutableCopy;
    dispatch_group_t group = dispatch_group_create();
    [assetsFetchResults enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
        [imageManager requestImageForAsset:asset
                                targetSize:SomeSize
                               contentMode:PHImageContentModeAspectFill
                                   options:option
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 
                                 // 得到一张 UIImage，展示到界面上
                                 NSLog(@"%@  thread:%@",result,[NSThread currentThread]);
                                [arr addObject:result];
                                 dispatch_group_leave(group);
                             }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (arr.count == 0) {
            return;
        }
        NSLog(@"%@",arr);
        [KYPhotoBrowserController showPhotoBrowserWithImages:arr.copy currentImageIndex:0 delegate:nil];
    });

}

@end
