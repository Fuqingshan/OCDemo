//
//  PropertyViewController.m
//  OC
//
//  Created by yier on 2019/2/18.
//  Copyright © 2019 yier. All rights reserved.
//

#import "PropertyViewController.h"
#import "PropertyCell.h"

@interface PropertyViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation PropertyViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"属性特性";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = LKHexColor(0xB2000000);
    [self.tableView registerNib:[UINib nibWithNibName:[PropertyCell cellReuseIdentifier] bundle:nil] forCellReuseIdentifier:[PropertyCell cellReuseIdentifier]];
}

- (void)initData{
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"type":@"原子性"
                            ,@"property":@"nonatomic"
                            ,@"des":@"使用该特性可以在多线程并发的情况中,将访问器设置为非原子性的,因而能够提供不同的结果。如果不设置该特性,访问器就会拥有原子性,换言之,赋值和返回结果永远都会完全同步"
                            }
                        ,@{
                            @"type":@"设置器语义"
                            ,@"property":@"assign"
                            ,@"des":@"通过该特性可以在不使用copy和 retain特性的情况下,使属性的设置器方法执行简单的赋值操作。这个特性是默认设置"
                            }
                        ,@{
                            @"type":@"设置器语义"
                            ,@"property":@"retain"
                            ,@"des":@"在赋值时,输入值会被发送一条保留消息,而上一个值会被发送一条释放消息"
                            }
                        ,@{
                            @"type":@"设置器语义"
                            ,@"property":@"copy"
                            ,@"des":@"在赋值时,输入值会被发送一条新消息的副本,而上一个值会被发送一条释放消息"
                            }
                        ,@{
                            @"type":@"设置器语义"
                            ,@"property":@"strong"
                            ,@"des":@"当属性使用ARC内存管理功能时,该特性等同于retain特性"
                            }
                        ,@{
                            @"type":@"设置器语义"
                            ,@"property":@"weak"
                            ,@"des":@"当属性使用ARC内存管理功能时,该特性的作用与assign特性类似,但如果引用对象被释放了,属性的值会被设置为nil"
                            }
                        ,@{
                            @"type":@"可读写性"
                            ,@"property":@"readwrite"
                            ,@"des":@"使用该特性时,属性可以被读取也可以被写入,而且必须实现getter和setter方法。这个特性是默认设置"
                            }
                        ,@{
                            @"type":@"可读写性"
                            ,@"property":@"readonly"
                            ,@"des":@"使用该特性时,会将属性设置为只读。必须实现 getter方法"
                            }
                        ,@{
                            @"type":@"方法名称"
                            ,@"property":@"getter=method"
                            ,@"des":@"将getter方法重命名为新读取器的名称"
                            }
                        ,@{
                            @"type":@"方法名称"
                            ,@"property":@"setter=method"
                            ,@"des":@"将setter方法重命名为新设置器的名称"
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
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *des = stringInDictionaryForKey(dic, @"des");

    return [PropertyCell cellHeightWithModel:des];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PropertyCell *cell = [tableView dequeueReusableCellWithIdentifier:[PropertyCell cellReuseIdentifier] forIndexPath:indexPath];
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    [cell fillCellWithModel:dic indexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *url = stringInDictionaryForKey(dic, @"url");
    [OCRouter openURL:[NSURL URLWithString:url]];
}

@end
