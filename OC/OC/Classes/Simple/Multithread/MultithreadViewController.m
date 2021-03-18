//
//  MultithreadViewController.m
//  OC
//
//  Created by yier on 2019/3/5.
//  Copyright © 2019 yier. All rights reserved.
//

#import "MultithreadViewController.h"
#import <objc/message.h>
#import <CKYPhotoBrowser/KYPhotoBrowserController.h>

@interface MultithreadViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation MultithreadViewController

/**
 并发：在操作系统中，是指一个时间段中有几个程序都处于已启动运行到运行完毕之间，且这几个程序都是在同一个处理机上运行，但任一个时刻点上只有一个程序在处理机上运行。
 并行：在操作系统中，一组程序按独立异步的速度执行，无论从微观还是宏观，程序都是一起执行的。
 例：并发和并行的区别就是一个人同时吃三个馒头和三个人同时吃三个馒头；
 
 在单CPU系统中，系统调度在某一时刻只能让一个线程运行，虽然这种调试机制有多种形式(大多数是时间片轮巡为主)，但无论如何，要通过不断切换需要运行的线程让其运行的方式就叫并发(concurrent)。而在多CPU系统中，可以让两个以上的线程同时运行，这种可以同时让两个以上线程同时运行的方式叫做并行(parallel)。
 
 并发通常指提高运行在单处理器上的程序的性能； "并发"在微观上不是同时执行的，只是把时间分成若干段，使多个进程快速交替的执行，从宏观外来看，好像是这些进程都在执行。
 使用多个线程可以帮助我们在单个处理系统中实现更高的吞吐量，如果一个程序是单线程的，这个处理器在等待一个同步I/O操作完成的时候，他仍然是空闲的。在多线程系统中，当一个线程等待I/O的同时，其他的线程也可以执行。
 
 异步：I/O操作不仅包括了直接的文件、网络的读写，还包括数据库操作、Web Service、HttpRequest以及.Net Remoting等跨进程的调用
 
 多线程：线程的适用范围则是那种需要长时间CPU运算的场合，例如耗时较长的图形处理和算法执行。但是往往由于使用线程编程的简单和符合习惯，所以很多朋友往往会使用线程来执行耗时较长的I/O操作。这样在只有少数几个并发操作的时候还无伤大雅，如果需要处理大量的并发操作时就不合适了
 
 多核cpu和多cpu：多cpu对应并行进程，多核cpu对应并行线程。
 */

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"多线程");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"多线程");
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                             @"content":@"多线程图示"
                             ,@"sel":@"showMutithreadImage"
                             }
                        ,@{
                            @"content":@"NSThread"
                            ,@"url":@"sumup://simple/multithread/thread"
                            }
                        ,@{
                            @"content":@"GCD"
                            ,@"url":@"sumup://simple/multithread/gcd"
                            }
                        ,@{
                            @"content":@"Queue"
                            ,@"url":@"sumup://simple/multithread/queue"
                            }
                        ,@{
                            @"content":@"PThread"
                            ,@"url":@"sumup://simple/multithread/pthread"
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

- (void)showMutithreadImage{
    [KYPhotoBrowserController showPhotoBrowserWithImages:@[[UIImage imageNamed:@"mutithread.png"]] currentImageIndex:0 delegate:nil];
}

@end
