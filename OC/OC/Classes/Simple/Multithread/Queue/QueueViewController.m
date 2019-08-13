//
//  QueueViewController.m
//  OC
//
//  Created by yier on 2019/3/6.
//  Copyright © 2019 yier. All rights reserved.
//

#import "QueueViewController.h"
#import <objc/message.h>

@interface QueueViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSOperationQueue * queueDependency;

@property (nonatomic, strong) NSConditionLock * conditionLock;
@property (nonatomic, strong) NSOperationQueue * operationQueue;
@property (nonatomic, strong) NSInvocationOperation * inOpe1;
@property (nonatomic, strong) NSInvocationOperation * inOpe2;
@property (nonatomic, assign) NSInteger pro;///<生产消费总数

@end

@implementation QueueViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"Queue";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = @"Queue";
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"OperationQueue"
                            ,@"sel":@"OperationQueueSelector"
                            }
                        ,@{
                            @"content":@"queueDependency"
                            ,@"sel":@"queueDependencySelector"
                            }
                        ,@{
                            @"content":@"生产销售系统"
                            ,@"sel":@"prosellSelector"
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

- (void)OperationQueueSelector{
    NSOperationQueue * bgQueue = [[NSOperationQueue alloc]init];
    //默认值就是NSOperationQueueDefaultMaxConcurrentOperationCount，会根据系统当前条件自动设置最大数
    [bgQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    NSInvocationOperation * operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(startProcessing) object:nil];
    [bgQueue addOperation:operation];
}

- (void)queueDependencySelector{
    self.queueDependency = [[NSOperationQueue alloc] init];
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(newThread) object:nil];
    
    //如果使用start，会在当前线程启动操作:这儿是主线程
    //[op1 start];
    
    //一旦将操作添加到操作队列，操作就会启动
    [self.queueDependency addOperation:op1];
}

- (void)newThread{
    [NSThread detachNewThreadSelector:@selector(updateImageUI) toTarget:self withObject:nil];
}

#pragma mark - 模仿网络下载图片
- (void)updateImageUI{
    // 1. 下载
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"\n下载 %@" , [NSThread currentThread]);
    }];
    // 2. 滤镜
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"\n滤镜 %@" , [NSThread currentThread]);
    }];
    // 3. 显示
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"\n更新UI %@" , [NSThread currentThread]);
        
    }];
    
    // 添加操作之间的依赖关系，所谓“依赖”关系，就是等待前一个任务完成后，后一个任务才能启动
    // 依赖关系可以跨线程队列实现
    // 提示：在指定依赖关系时，注意不要循环依赖，否则不工作。
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    //    [op1 addDependency:op3];
    
    [self.queueDependency addOperation:op1];
    [self.queueDependency addOperation:op2];
    
    //更新ui两种方式
    //第一种队列
    [[NSOperationQueue mainQueue] addOperation:op3];
    
    //第二种不需要单独用NSBlockOperation
    //    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
    //          NSLog(@"更新UI %@" , [NSThread currentThread]);
    //    }];
}

#pragma mark - 模拟大数据处理或网络请求过程
- (void)startProcessing
{
    @autoreleasepool{
        
        NSDate *startDate = [NSDate date];
        NSLog(@"begin");
        [NSThread sleepForTimeInterval:2];//休眠2秒钟
        NSDate * endDate = [NSDate date];
        NSLog(@"时间差：%f",[endDate timeIntervalSinceDate:startDate]);
        //回到主线程,最后一个参数表示不阻塞
        [self performSelectorOnMainThread:@selector(finishProcessing) withObject:nil waitUntilDone:NO];
    }
}

- (void)finishProcessing{
    NSLog(@"线程模拟完成--- isMain:%u",[NSThread isMainThread]);
}

#pragma mark - 生产销售系统
- (void)prosellSelector{
    self.pro = 0;//初始生产总数为0
    
    self.conditionLock = [[NSConditionLock alloc] initWithCondition:0];
    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:2];
    
    self.inOpe1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operationRun1) object:nil];
    self.inOpe2 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operationRun2) object:nil];
    [self.operationQueue addOperations:@[self.inOpe1,self.inOpe2] waitUntilFinished:NO];
}

#pragma mark - 线程互斥条件锁
/**
 初始condition是0，进入生产，生产1之后解锁，condition为1开始销售，直到销售完之后解锁为0，又开始生产，无限循环
 */
- (void)operationRun1
{
    while (YES) {
        [self.conditionLock lockWhenCondition:0];
        self.pro++;
        NSLog(@"生产:%zd 当前线程：%@",self.pro,[NSThread currentThread]);
        [self.conditionLock unlockWithCondition:1];
    }
}

- (void)operationRun2
{
    while (YES) {
        [self.conditionLock lockWhenCondition:1];
        self.pro--;
        NSLog(@"销售: %zd 当前线程：%@",self.pro,[NSThread currentThread]);
        [self.conditionLock unlockWithCondition:(self.pro == 0)?0:1];
    }
}

@end
