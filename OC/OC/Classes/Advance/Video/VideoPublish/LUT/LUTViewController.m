//
//  LUTViewController.m
//  OC
//
//  Created by yier on 2021/4/14.
//  Copyright © 2021 yier. All rights reserved.
//

#import "LUTViewController.h"
#import "CIFilter+ColorLUT.h"

@interface LUTViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *originImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lutImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lutTransformImageView;

@property(nonatomic, strong) NSArray *lutArrays;
@property(nonatomic, assign) NSInteger currentIndex;
@end

@implementation LUTViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
}

- (void)initData{
    //这是图片都是在LUT标准色彩图的基础上用Photoshop修改饱和度等参数完成的
    self.lutArrays = @[
    @"lut_black.png",
    @"lut_0.png",
    @"lut_1.png",
    @"lut_2.png",
    @"lut_3.png",
    @"lut_4.png",
    @"lut_5.png",
    @"lut_6.png",
    @"lut_7.png",
    //下面这三种是用来做脸部的滤镜
    @"清晰.png",
    @"桃花.png",
    @"纯真.png"
    ];
    
    self.currentIndex = 0;
}

- (void)setupUI{
    UIImage *originImage = [UIImage imageNamed:@"LUT测试.png"];
    //这个标准图有64个格子，因此填64, 如果
    UIImage *newImage = [CIFilter transformImageByOriginImage:originImage lutImageNamed:@"LUT标准色彩图.png" dimension:64];
    [self.originImageView setImage:originImage];
    [self.lutImageView setImage:newImage];
    [self changeEvent];
    
    UIButton *changeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [changeBtn setTitle:@"变换" forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeEvent) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *changeItem = [[UIBarButtonItem alloc] initWithCustomView:changeBtn];
    self.navigationItem.rightBarButtonItem = changeItem;
}

- (void)changeEvent{
    NSString *lutName = stringInArrayAtIndex(self.lutArrays, self.currentIndex);
    if (lutName.length == 0) {
        self.currentIndex = 0;
        lutName = stringInArrayAtIndex(self.lutArrays, self.currentIndex);
    }
    
    self.currentIndex += 1;
    UIImage *originImage = [UIImage imageNamed:@"LUT测试.png"];
    UIImage *newImage = [CIFilter transformImageByOriginImage:originImage lutImageNamed:lutName dimension:64];
    [self.lutTransformImageView setImage:newImage];
}

@end
