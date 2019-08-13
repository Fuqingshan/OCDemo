//
//  IntroductionViewController.m
//  OC
//
//  Created by yier on 2019/2/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "IntroductionViewController.h"

@interface IntroductionViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation IntroductionViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"入门";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];    
}

#pragma mark - setupUI

#pragma mark - initData
- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"属性特性"
                            ,@"url":@"sumup://simple/introduction/property"
                            }
                        ,@{
                            @"content":@"alloc之后为什么需要init"
                            ,@"des":@"alloc方法为对象分配了内存，但是并没有将对象初始化为适当的值，也没有为对象准备其他必须的对象和资源"
                            }
                        ,@{
                            @"content":@"Constructor"
                            ,@"url":@"sumup://simple/introduction/constructor"
                            }
                        ,@{
                            @"content":@"Protocol"
                            ,@"url":@"sumup://simple/introduction/protocol"
                            }
                        ,@{
                            @"content":@"消息与转发"
                            ,@"url":@"sumup://simple/introduction/msgforward"
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
    NSString *url = stringInDictionaryForKey(dic, @"url");
    if ([url isValide]) {
        [OCRouter openURL:[NSURL URLWithString:url]];
    }else{
        NSString *des = stringInDictionaryForKey(dic, @"des");
        [self performSelectorOnMainThread:@selector(showDes:) withObject:des waitUntilDone:NO];
    }
}

- (void)showDes:(NSString *)des{
    if (![des isValide]) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:des preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"了解" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    //上面不用performSelectorOnMainThread派发到mainRunloop的话，这儿就需要唤醒mainRunloop
    //    CFRunLoopWakeUp(CFRunLoopGetMain());
    [self presentViewController:alert animated:YES completion:nil];
}

@end
