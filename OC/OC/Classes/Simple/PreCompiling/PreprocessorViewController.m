//
//  PreprocessorViewController.m
//  OC
//
//  Created by yier on 2019/2/22.
//  Copyright © 2019 yier. All rights reserved.
//

#import "PreprocessorViewController.h"
#import <objc/message.h>
#import <CKYPhotoBrowser/KYPhotoBrowserController.h>

@interface PreprocessorViewController()<UITabBarDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation PreprocessorViewController

#ifndef DEBUG
#define DEBUG
#endif

#ifndef DEBUG
#error "时代大厦"
#endif

#warning 测试warning
/*
 define定义宏
 undef移除宏
 */
- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"预处理");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"预处理");
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"object-c源文件的编译过程"
                            ,@"sel":@"compilingImage"
                            }
                        ];
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
    SEL sel = NSSelectorFromString(selStr);
    ((void(*)(id,SEL))objc_msgSend)(self,sel);
    //有返回值
    //    ((NSString *(*)(id,SEL))objc_msgSend)(self,sel);
}

- (void)compilingImage{
    [KYPhotoBrowserController showPhotoBrowserWithImages:@[[UIImage imageNamed:@"oc原文件编译过程.png"]] currentImageIndex:0 delegate:nil];
}

@end
