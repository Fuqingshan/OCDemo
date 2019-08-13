//
//  MemoryViewController.m
//  OC
//
//  Created by yier on 2019/2/21.
//  Copyright © 2019 yier. All rights reserved.
//

#import "MemoryViewController.h"

@interface MemoryViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation MemoryViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"内存");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)getDataSource{
    NSDictionary *dic = @{
                          @"urlStr":@"https://blog.csdn.net/qq_41145352/article/details/80617905"
                          ,@"ignoreWebTitle":@"0"
                          };
    NSURLComponents *components = [NSString mapQuerysURLByDictionary:dic url:@"sumup://common/web"];
    
    self.dataSource = @[
                        @{
                            @"content":LocalizedString(@"安卓GC")
                            ,@"url":nilToEmptyString(components.URL.absoluteString)
                            }
                        ,@{
                            @"content":LocalizedString(@"内存管理")
                            ,@"url":@"sumup://simple/memory/ocmemory"
                            }
                        ,@{
                            @"content":@"ARC"
                            ,@"url":@"sumup://simple/memory/arc"
                            }
                        ,@{
                            @"content":@"常规的数据存储"
                            ,@"url":@"sumup://simple/memory/savedata"
                            }
                        ];
    
    [self.tableView reloadData];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"内存");
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
