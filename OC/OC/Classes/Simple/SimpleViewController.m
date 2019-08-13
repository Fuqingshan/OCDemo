//
//  SimpleViewController.m
//  OC
//
//  Created by yier on 2019/2/12.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SimpleViewController.h"

@interface SimpleViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation SimpleViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"简单");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self setupBarButtons];
}

- (void)setupBarButtons{
    UIButton *photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [photoBtn setImage:[UIImage imageNamed:@"mine.png"] forState:UIControlStateNormal];
    [photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(tapPhotoEvent) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *photoItem = [[UIBarButtonItem alloc] initWithCustomView:photoBtn];
    self.navigationItem.leftBarButtonItem = photoItem;
    
    UIButton *QRCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [QRCodeBtn setImage:[UIImage imageNamed:@"simple_QRCode.png"] forState:UIControlStateNormal];
    [QRCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [QRCodeBtn addTarget:self action:@selector(tapQRCodeEvent) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *QRCodeItem = [[UIBarButtonItem alloc] initWithCustomView:QRCodeBtn];
    self.navigationItem.rightBarButtonItem = QRCodeItem;
}

- (void)tapPhotoEvent{
    [OCRouter openURL:[NSURL URLWithString:@"sumup://mine"]];
}

- (void)tapQRCodeEvent{
    [OCRouter openURL:[NSURL URLWithString:@"sumup://simple/QRCode"]];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"简单");
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":LocalizedString(@"OC优势")
                            ,@"url":@"sumup://simple/advantage"
                            }
                        ,@{
                            @"content":LocalizedString(@"入门")
                            ,@"url":@"sumup://simple/introduction"
                            }
                        ,@{
                            @"content":LocalizedString(@"内存")
                            ,@"url":@"sumup://simple/memory"
                            }
                        ,@{
                            @"content":LocalizedString(@"Foundation")
                            ,@"url":@"sumup://simple/foundation"
                            }
                        ,@{
                            @"content":LocalizedString(@"预处理")
                            ,@"url":@"sumup://simple/preprocessor"
                            }
                        ,@{
                            @"content":LocalizedString(@"多线程")
                            ,@"url":@"sumup://simple/multithread"
                            }
                        ,@{
                            @"content":LocalizedString(@"调试")
                            ,@"url":@"sumup://simple/debug"
                            }
                        ,@{
                            @"content":LocalizedString(@"安全")
                            ,@"url":@"sumup://simple/security"
                            }
                        ,@{
                            @"content":LocalizedString(@"UI控件")
                            ,@"url":@"sumup://simple/uicontrol"
                            }
                        ,@{
                            @"content":LocalizedString(@"动画")
                            ,@"url":@"sumup://simple/animation"
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
    [OCRouter openURL:[NSURL URLWithString:url]];
}

@end
