//
//  VideoViewController.m
//  OC
//
//  Created by yier on 2019/8/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "VideoViewController.h"
#import <objc/message.h>

@interface VideoViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation VideoViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"视频");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"视频");
     [self getDataSource];
}


#pragma mark - setupUI

#pragma mark - initData
- (void)initData{
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"AVFoundation"
                            ,@"url":@"sumup://advance/video/avfoundation"
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



@end
