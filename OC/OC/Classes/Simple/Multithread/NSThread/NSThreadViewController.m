//
//  NSThreadViewController.m
//  OC
//
//  Created by yier on 2019/3/5.
//  Copyright © 2019 yier. All rights reserved.
//

#import "NSThreadViewController.h"
#import <objc/message.h>

@interface NSThreadViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSThread * threadA;///<A售票口
@property (nonatomic, strong) NSThread * threadB;///<B售票口
@property (nonatomic, assign) NSInteger sumVotes;///<总票数
@property (nonatomic, assign) NSInteger sellVotes;///<已卖票数
@end

@implementation NSThreadViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"NSThread";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = @"NSThread";
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"detachNewThread"
                            ,@"sel":@"detachNewThreadSelector"
                            }
                        ,@{
                            @"content":@"allocThread"
                            ,@"sel":@"allocThreadSelector"
                            }
                        ,@{
                            @"content":@"performBackgroundThread"
                            ,@"sel":@"performBackgroundThreadSelector"
                            }
                        ,@{
                            @"content":@"售票系统"
                            ,@"sel":@"lockSelector"
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

- (void)detachNewThreadSelector{
    [NSThread detachNewThreadSelector:@selector(startProcessing) toTarget:self withObject:nil];
}

- (void)allocThreadSelector{
    NSThread *bgThread = [[NSThread alloc]initWithTarget:self selector:@selector(startProcessing) object:nil];
    [bgThread start];
}

- (void)performBackgroundThreadSelector{
    [self performSelectorInBackground:@selector(startProcessing) withObject:nil];
}

#pragma mark - 模拟大数据处理或网络请求过程
- (void)startProcessing
{
    @autoreleasepool
    {
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

#pragma mark - 售票系统
- (void)lockSelector{
    self.sumVotes = 100;///<总数100张票
    self.sellVotes = 0;
    
    self.lock = [[NSLock alloc]init];
    
    self.threadA = [[NSThread alloc]initWithTarget:self selector:@selector(threadRun:) object:nil];
    self.threadB = [[NSThread alloc]initWithTarget:self selector:@selector(threadRun:) object:nil];
    [self.threadA setName:@"threadA"];
    [self.threadB setName:@"threadB"];
    [self.threadA start];
    [self.threadB start];
}

#pragma mark - 同步,两个窗口同时卖票，当总票数卖完时，两个while循环break
- (void)threadRun:(NSThread *)sender
{
    @autoreleasepool {
        while (YES)
        {
            [self.lock lock];
            
            //当票买完时退出系统
            if (self.sumVotes<0) {
                
                NSLog(@"break当前线程：%@",[[NSThread currentThread] name]);
                [self.lock unlock];
                break;
            }
            
            self.sellVotes= 100 - self.sumVotes;
            NSLog(@"当前票数：%zd  卖出：%zd 当前线程名：%@",self.sumVotes,self.sellVotes,[[NSThread currentThread]name]);
            self.sumVotes --;
            
            [self.lock unlock];
        }
    }
}

@end
