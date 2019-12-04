//
//  DesignModeViewController.m
//  OC
//
//  Created by yier on 2019/8/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "DesignModeViewController.h"
#import <objc/message.h>

#import "FactoryChild1.h"
#import "FactoryChild2.h"
#import "FactoryChild3.h"

#import "SignalMode.h"

#import "ObserverMode.h"

#import "FacadeModeManager.h"

#import "SnapshootForMemo.h"

#import "AdapterMode.h"

@interface DesignModeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation DesignModeViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"设计模式");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"设计模式");
}

- (void)initData{
    
    self.dataSource = @[
                        @{
                            @"content":@"工厂模式"
                            ,@"sel":@"factorySelector"
                            }
                        ,@{
                            @"content":@"单例模式"
                            ,@"sel":@"signalSelector"
                            }
                        ,@{
                            @"content":@"观察者模式"
                            ,@"sel":@"observerSelector"
                            }
                        ,@{
                            @"content":@"外观模式（门面模式）"
                            ,@"sel":@"facadeSelector"
                            }
                        ,@{
                            @"content":@"备忘录模式"
                            ,@"sel":@"memoSelector"
                            }
                        ,@{
                            @"content":@"适配器模式"
                            ,@"sel":@"adapterSelector"
                            }
                        ,@{
                            @"content":@"MVVM"
                            ,@"url":@"sumup://advance/designmode/login"
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

#pragma mark - 工厂模式
/**
 1、简单工厂：简单工厂模式是由一个工厂对象决定创建出哪一种产品类的实例。简单工厂模式是工厂模式家族中最简单实用的模式，可以理解为是不同工厂模式的一个特殊实现。（例：manager传入type生成对应的类型返回，缺点是不易扩展）
 2、工厂模式：抽象了工厂接口的具体产品，应用程序的调用不同工厂创建不同产品对象。（抽象产品）（factorySelector例子，用NSClassFromString避免写太多的产品类）
 3、抽象工厂模式：在工厂模式的基础上抽象了工厂，应用程序调用抽象的工厂发发创建不同产品对象，用法复杂，不好扩展。（抽象产品+抽象工厂）
 */
- (void)factorySelector{
    NSArray *classes = @[
                         @"FactoryChild1"
                         ,@"FactoryChild2"
                         ,@"FactoryChild3"
                         ];
    for (NSString *className in classes) {
        Class class = NSClassFromString(className);
        id child = [[class alloc] init];
        if ([child conformsToProtocol:@protocol(FactoryProtocol)]) {
            [child test];
        }
    }
}

#pragma mark - 单例模式
- (void)signalSelector{
    SignalMode *signal = [SignalMode shareInstance];
    [signal test];
}

#pragma mark - 观察者模式
- (void)observerSelector{
    ObserverMode *observer = [[ObserverMode alloc] init];
    [observer subscribe];
    [observer observable];
}

#pragma mark - 外观模式
/**
 部与一个子系统的通信必须通过一个统一的外观对象进行，为子系统中的一组接口提供一个一致的界面，外观模式定义了一个高层接口，这个接口使得这一子系统更加容易使用。外观模式又称为门面模式，它是一种对象结构型模式。
 */
- (void)facadeSelector{
    FacadeModeManager *manager = [[FacadeModeManager alloc] init];
    [manager facade1Test];
    [manager facade2Test];
}

#pragma mark - 备忘录模式
/**
 备忘录模式（Memento Pattern）又叫做快照模式（Snapshot Pattern）或Token模式，是GoF的23种设计模式之一，属于行为模式。
 定义：在不破坏封闭的前提下，捕获一个对象的内部状态，并在该对象之外保存这个状态。这样以后就可将该对象恢复到原先保存的状态。
 */
- (void)memoSelector{
    MemoMode *mode = [[MemoMode alloc] init];
    mode.name = @"yier";
    mode.age = 123;
    
    //保存快照
    [SnapshootForMemo save:mode];
    NSLog(@"%@",[mode description]);

    mode.name = @"tom";
    mode.age = 1;
    NSLog(@"%@",[mode description]);
    
    //读取快照
    mode = [SnapshootForMemo read];
    NSLog(@"%@",[mode description]);
}

#pragma mark - 适配器模式
/**
 将一个类的接口转换成客户希望的另外一个接口。Adapter模式使得原本由于接口不兼容而不能一起工作的那些类可以在一起工作。
 意思是将不兼容的转换为兼容，如电源适配器，将全世界各种不相同的电压转换成相同的电压输出给目标设备。相当于一个中转层。
 
 类适配器: 通过继承来适配两个接口
 对象适配器: 不继承被适配者, 他们是一个关联关系,相当于引用了这个类
 */
- (void)adapterSelector{
    //对象适配器的例子
    id<AdapterProtocol> mode = [[AdapterMode alloc] init];
    [mode test];
}

#pragma mark - mvvm
- (void)mvvmSelector{
    
}

@end
