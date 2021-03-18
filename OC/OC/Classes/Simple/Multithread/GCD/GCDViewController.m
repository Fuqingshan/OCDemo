//
//  GCDViewController.m
//  OC
//
//  Created by yier on 2019/3/5.
//  Copyright © 2019 yier. All rights reserved.
//

#import "GCDViewController.h"
#import <objc/message.h>
#import <SDWebImage/SDWebImage.h>

typedef NS_ENUM(NSInteger,SourceType) {
    SourceTypeUnusable = 0,///<无法使用
    SourceTypeResume = 1,///<使用中
    SourceTypeSuspend = 2,///<暂停
};

@interface GCDViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSRecursiveLock *recursiveLock;
@property (nonatomic, copy) NSString *recursiveStr;

@property (strong, nonatomic) dispatch_source_t timer;
@property (nonatomic, strong) dispatch_source_t refreshListSource;
@property (nonatomic, assign) SourceType type;///<0表示无法使用,1表示使用中，2表示暂停

@property (nonatomic, strong) UIImageView *downloadImg;

@end

@implementation GCDViewController

/*
 uintptr_t dispatch_source_get_handle(dispatch_source_t source); //得到dispatch源创建，即调用dispatch_source_create的第二个参数
 unsignedlong dispatch_source_get_mask(dispatch_source_t source); //得到dispatch源创建，即调用dispatch_source_create的第三个参数
 void dispatch_source_cancel(dispatch_source_t source); //取消dispatch源的事件处理--即不再调用block。如果调用dispatch_suspend只是暂停dispatch源。
 long dispatch_source_testcancel(dispatch_source_t source); //检测是否dispatch源被取消，如果返回非0值则表明dispatch源已经被取消
 void dispatch_source_set_cancel_handler(dispatch_source_t source, dispatch_block_t cancel_handler); //dispatch源取消时调用的block，一般用于关闭文件或socket等，释放相关资源
 void dispatch_source_set_registration_handler(dispatch_source_t source, dispatch_block_t registration_handler); //可用于设置dispatch源启动时调用block，调用完成后即释放这个block。也可在dispatch源运行当中随时调用这个函数。
 
 注意：
 1、dispatch_source_set_event_handler会引起循环引用
 2、dispatch_resume和dispatch_suspend调用次数需要平衡，如果重复调用dispatch_resume则会崩溃,因为重复调用会让dispatch_resume代码里if分支不成立，从而执行了DISPATCH_CLIENT_CRASH("Over-resume of an object")导致崩溃
 3、source在suspend状态下，如果直接设置source = nil
 或者重新创建source都会造成crash。正确的方式是在resume状态下调用dispatch_source_cancel(source)释放当前的source
 */

- (void)dealloc{
    [self DispatchSourceSelectorCancle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"GCD";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = @"GCD";
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"NSRecursiveLock"
                            ,@"sel":@"NSRecursiveLockSelector"
                            }
                        ,@{
                            @"content":@"计算重复工作的i平均时间"
                            ,@"sel":@"BenchmarkSelector"
                            }
                        ,@{
                            @"content":@"CorruptedArray"
                            ,@"sel":@"CorruptedArraySelector"
                            }
                        ,@{
                            @"content":@"DispatchAfter"
                            ,@"sel":@"DispatchAfterSelector"
                            }
                        ,@{
                            @"content":@"DispatchGroup"
                            ,@"sel":@"DispatchGroupSelector"
                            }
                        ,@{
                            @"content":@"GCDTimer"
                            ,@"sel":@"GCDTimerSelector"
                            }
                        ,@{
                            @"content":@"DispatchSource"
                            ,@"sel":@"DispatchSourceSelector"
                            }
                        ,@{
                            @"content":@"DispatchSourceSelectorResume"
                            ,@"sel":@"DispatchSourceSelectorResume"
                            }
                        ,@{
                            @"content":@"DispatchSourceSelectorSuspend"
                            ,@"sel":@"DispatchSourceSelectorSuspend"
                            }
                        ,@{
                            @"content":@"DispatchSourceSelectorCancle"
                            ,@"sel":@"DispatchSourceSelectorCancle"
                            }
                        ,@{
                            @"content":@"DispatchSourceFile"
                            ,@"sel":@"DispatchSourceFileSelector"
                            }
                        ,@{
                            @"content":@"DispatchSuspend"
                            ,@"sel":@"DispatchSuspendSelector"
                            }
                        ,@{
                            @"content":@"SemaphoreAsync"
                            ,@"sel":@"SemaphoreAsyncSelector"
                            }
                        ,@{
                            @"content":@"SemaphoreSync"
                            ,@"sel":@"SemaphoreSyncSelector"
                            }
                        ,@{
                            @"content":@"dispatchSetTargetQueueDemo"
                            ,@"sel":@"dispatchSetTargetQueueDemo"
                            }
                        ,@{
                            @"content":@"dispatchBarrierAsyncDemo"
                            ,@"sel":@"dispatchBarrierAsyncDemo"
                            }
                        ,@{
                            @"content":@"dispatchApplyDemo"
                            ,@"sel":@"dispatchApplyDemo"
                            }
                        ,@{
                            @"content":@"dispatchCreateBlockDemo"
                            ,@"sel":@"dispatchCreateBlockDemo"
                            }
                        ,@{
                            @"content":@"dispatchBlockWaitDemo"
                            ,@"sel":@"dispatchBlockWaitDemo"
                            }
                        ,@{
                            @"content":@"dispatchBlockNotifyDemo"
                            ,@"sel":@"dispatchBlockNotifyDemo"
                            }
                        ,@{
                            @"content":@"dispatchBlockCancelDemo"
                            ,@"sel":@"dispatchBlockCancelDemo"
                            }
                        ,@{
                            @"content":@"dispatchGroupWaitDemo"
                            ,@"sel":@"dispatchGroupWaitDemo"
                            }
                        ,@{
                            @"content":@"deadLockCase1"
                            ,@"sel":@"deadLockCase1"
                            }
                        ,@{
                            @"content":@"deadLockCase2"
                            ,@"sel":@"deadLockCase2"
                            }
                        ,@{
                            @"content":@"deadLockCase3"
                            ,@"sel":@"deadLockCase3"
                            }
                        ,@{
                            @"content":@"deadLockCase4"
                            ,@"sel":@"deadLockCase4"
                            }
                        ,@{
                            @"content":@"deadLockCase5"
                            ,@"sel":@"deadLockCase5"
                            }
                        ,@{
                            @"content":@"下载图片实例"
                            ,@"sel":@"downloadImgSelector"
                            }
                        ,@{
                            @"content":@"enter-level"
                            ,@"sel":@"enterLevelSelector"
                        }
                        ,@{
                            @"content":@"groupAsync"
                            ,@"sel":@"groupAsyncSelector"
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
    @try {
        ((void(*)(id,SEL))objc_msgSend)(self,sel);
        //有返回值
        //    ((NSString *(*)(id,SEL))objc_msgSend)(self,sel);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    } @finally {
        
    }
}

/**
 递归锁可以被同一线程多次请求，而不会引起死锁。
 这主要是用在循环或递归操作中在调用lock之前，NSLock必须先调用unlock。
 但是递归锁不然,NSRecursiveLock允许在被解锁前锁定多次。如果解锁的次数与锁定的次数相匹配，则认为锁被释放，其他线程可以获取锁。
 当类中有多个方法使用同一个锁进行同步，且其中一个方法调用另一个方法时，NSRecursiveLock 非常有用。
 */
- (void)NSRecursiveLockSelector{
    if (!self.recursiveLock) {
        self.recursiveLock = [[NSRecursiveLock alloc] init];
    }
    [self NSRecursiveLockStart];
}

- (void)NSRecursiveLockStart{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++) {
            self.recursiveStr = @"NSRecursiveLockStart😢";
            [self NSRecursiveLockSafeMethod1];
            sleep(1);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++) {
            self.recursiveStr = @"NSRecursiveLockStart😁";
            [self NSRecursiveLockSafeMethod1];
            sleep(1);
        }
    });
}


- (void)NSRecursiveLockSafeMethod1{
    [self.recursiveLock lock];
    sleep(2);
    NSLog(@"NSRecursiveLockSafeMethod1 --- %@",self.recursiveStr);
    [self NSRecursiveLockSafeMethod2];
    [self.recursiveLock unlock];
}

- (void)NSRecursiveLockSafeMethod2{
    [self.recursiveLock lock];
    sleep(1);
    NSLog(@"NSRecursiveLockSafeMethod2 ---- %@",self.recursiveStr);
    [self.recursiveLock unlock];
}

- (void)BenchmarkSelector{
    uint64_t dispatch_benchmark(size_t count, void (^block)(void));
    size_t const objectCount = 1000;
    uint64_t n = dispatch_benchmark(10000, ^{
        @autoreleasepool {
            id obj = @42;
            NSMutableArray *array = [NSMutableArray array];
            for (size_t i = 0; i < objectCount; ++i) {
                [array addObject:obj];
            }
        }
    });
    NSLog(@"-[NSMutableArray addObject:] : %llu ns", n);
}

- (void)CorruptedArraySelector{
    dispatch_queue_t queue = dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT , 0) ;
    NSMutableArray *array = [[NSMutableArray alloc ]init] ;
    @try {
        for ( int i = 0 ; i < 100000 ; ++i) {
            dispatch_async(queue , ^ {
                [array addObject:[NSNumber numberWithInt:i]];
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"error:%@",exception);
        NSLog(@"async破坏了array的malloc,同步没事");
    } @finally {
        NSLog(@"end");
    }
}

- (void)DispatchAfterSelector{
    //主线程延时2秒
    //walltime现实中的挂钟时间
    dispatch_after(dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"延时2秒");
    });
}

- (void)DispatchGroupSelector{
    //创建一个分组
    dispatch_group_t group = dispatch_group_create();
    //创建一个队列
    dispatch_queue_t queue = dispatch_queue_create("000", DISPATCH_QUEUE_CONCURRENT);
    //向分组中添加一个任务
    dispatch_group_async(group, queue, ^{
        NSLog(@"1");    });
    //向分组添加 最后执行的任务(不能添加为第一个)
    dispatch_group_notify(group, queue, ^{
        NSLog(@"last one");
    });
    //将任务添加到队列,此任务执行的时候,其他任务停止执行,所以它输出顺序不改变
    dispatch_barrier_async(queue, ^{
        NSLog(@"不变位置的2");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"3");
    });
}


/**
 NSTimer和runloop挂钩，如果在子线程使用，默认子线程没有开启runloop，需要获取一次runloop来创建新的，要么用dispatch_source_set_timer
 
 dispatch_source_t主要用于计时操作，其原因是因为它创建的timer不依赖于RunLoop，且计时精准度比NSTimer高
 
 注意：
 GCDTimer需要强持有，否则出了作用域立即释放，也就没有了事件回调
 GCDTimer默认是挂起状态，需要手动激活
 GCDTimer没有repeat，需要封装来增加标志位控制
 GCDTimer如果存在循环引用，使用weak+strong或者提前调用dispatch_source_cancel取消timer
 dispatch_resume和dispatch_suspend调用次数需要平衡
 source在挂起状态下，如果直接设置source = nil或者重新创建source都会造成crash.正确的方式是在激活状态下调用dispatch_source_cancel(source)释放当前的source
 */
- (void)GCDTimerSelector{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    if (!self.timer) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        //开始时间，从现在开始1秒之后
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        //间隔时间1秒调用一次
        uint64_t interval = 1.0 * NSEC_PER_SEC;
        dispatch_source_set_timer(self.timer, start, interval, 0);
        
        //设置回调次数
        __block int num = 10;
        
        //设置回调
        dispatch_source_set_event_handler(self.timer, ^{
            num -- ;
            if (num == 0) {
                //10秒之后暂停
//                dispatch_suspend(self.timer);
                dispatch_source_cancel(self.timer);
            }
            NSLog(@"----GCDTimerSelector---");
        });
        
        dispatch_source_set_cancel_handler(self.timer, ^{
            NSLog(@"----GCDTimerEnd---");
        });
        
        //启动timer
        dispatch_resume(self.timer);
    }
}

/**
 dispatch_queue不能取消，dispatch_source可以
 
以吃瓜为例：
 你准备吃100个瓜，机器加工瓜，设置好加工100个，当你吃到50个的时候吃不下了，可以暂停或放弃
 
 DISPATCH_SOURCE_TYPE_DATA_ADD
 当同一时间，一个事件的的触发频率很高，那么Dispatch Source会将这些响应以ADD的方式进行累积，然后等系统空闲时最终处理，如果触发频率比较零散，那么Dispatch Source会将这些事件分别响应。相当于短时间降低事件触发频率。
 
 设置响应dispatch源事件的block，在dispatch源指定的队列上运行
 可以通过dispatch_source_get_data(source)来得到dispatch源数据
 
 应用：ps:有点像RAC的throttle,不过throttle用的是timeSinceNow实现的
 1、更新进度条UI
 2、降低聊天界面密集收到消息的刷新table压力
 */
- (void)DispatchSourceSelector{
    if (!self.refreshListSource) {
        self.refreshListSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_global_queue(0, 0));
        
        __block NSUInteger totalComplete = 0;
        @weakify(self);
        dispatch_source_set_event_handler(self.refreshListSource, ^{
            @strongify(self);
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSUInteger value = dispatch_source_get_data(self.refreshListSource);
                totalComplete += value;
                NSLog(@"吃瓜进度：%@", @((float)totalComplete/100));
                NSLog(@"🔵线程号：%@", [NSThread currentThread]);
            });
        });
        
        dispatch_source_set_cancel_handler(self.refreshListSource, ^{
            NSLog(@"cancle之后关闭文件什么的");
        });
        
        dispatch_resume(self.refreshListSource);
        self.type = SourceTypeResume;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"开始生产瓜");
        //合并dispatch源数据，在dispatch源的block中，dispatch_source_get_data(source)就会得到value。
        for (NSInteger i = 0; i< 100; i++) {
            //通知队列
            if (self.type != SourceTypeResume) {
//                usleep(200000);//0.02秒
                [NSThread sleepForTimeInterval:0.02];
                continue;
            }
            dispatch_source_merge_data(self.refreshListSource, 1);
            NSLog(@"生产瓜 --- ♻️线程号：%@", [NSThread currentThread]);
//            usleep(200000);//0.02秒
            [NSThread sleepForTimeInterval:0.02];
        }
    });
}

- (void)DispatchSourceSelectorResume{
    if (self.type != SourceTypeSuspend) {
        NSLog(@"暂停状态才能继续使用");
        return;
    }
    dispatch_resume(self.refreshListSource);
    self.type = SourceTypeResume;
}

- (void)DispatchSourceSelectorSuspend{
    if (self.type != SourceTypeResume) {
        NSLog(@"使用状态才能暂停");
        return;
    }
    dispatch_suspend(self.refreshListSource);
    self.type = SourceTypeSuspend;
}

- (void)DispatchSourceSelectorCancle{
    if (self.type == SourceTypeUnusable) {
        NSLog(@"无法使用状态不能cancle");
        return;
    }
    
    if (self.type == SourceTypeSuspend) {
        NSLog(@"如果当前处理暂停状态，需要启动起来才能cancle");
        dispatch_resume(self.refreshListSource);
        self.type = SourceTypeResume;
    }
    
    if (dispatch_source_testcancel(self.refreshListSource) != 0) {
        NSLog(@"已经被cancle了");
        return;
    }
    dispatch_source_cancel(self.refreshListSource);
    self.type = SourceTypeUnusable;
    self.refreshListSource = nil;
}


- (void)DispatchSourceFile{
    NSString *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    
    NSString*ksnowDir=[path stringByAppendingPathComponent:@"ksnow"];
    NSLog(@"ksnowdir = %@",ksnowDir);
    
    NSURL*directoryURL=[NSURL URLWithString:ksnowDir];
    int const fd = open([[directoryURL path]fileSystemRepresentation],O_EVTONLY);
    
    if(fd < 0){
        NSLog(@"Unable to open the path = %@",[directoryURL path]);
        return;
    }
    /*
     Timer Dispatch Source：定时器事件源，用来生成周期性的通知或回调
     Signal Dispatch Source：监听信号事件源，当有UNIX信号发生时会通知
     Descriptor Dispatch Source：监听文件或socket事件源，当文件或socket数据发生变化时会通知
     Process Dispatch Source：监听进程事件源，与进程相关的事件通知
     Mach port Dispatch Source：监听Mach端口事件源
     Custom Dispatch Source：监听自定义事件源
     */
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,fd,DISPATCH_VNODE_DELETE|DISPATCH_VNODE_WRITE|DISPATCH_VNODE_RENAME,DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_event_handler(source,^(){
        unsigned long const type = dispatch_source_get_data(source);
        switch(type){
                //文件被删除时，停止监听
            case DISPATCH_VNODE_DELETE:
            {
                NSLog(@"目录文件已被删除，停止监听!!!");
                dispatch_source_cancel(source);
            }
                break;
            case DISPATCH_VNODE_WRITE:
            {
                NSLog(@"目录内容改变!!!");
            }
                break;
            case DISPATCH_VNODE_RENAME:
            {
                NSLog(@"目录被重命名!!!");
            }
                break;
            default:
                break;
        }});
    
    dispatch_source_set_cancel_handler(source,^(){
        close(fd);
    });
    dispatch_resume(source);
}

/**
 dispatch_suspend并不会立即暂停正在运行的block，而是在当前block执行完成后，暂停后续的block执行。
 dispatch_group_wait，当前线程暂停，等待group执行完成，再往后执行
 下面执行顺序:
 
 一、如果有dispatch_suspend：
 1.任务1-q1，任务1-q2执行
 2.wait group,因为任务1-q1、任务2-q2卡住了，所以暂停1和暂停2需要等待任务1-q1、任务2-q2执行完成
 3.然后执行group的暂停，执行完成之后在往下走
 
 二、如果删除dispatch_suspend和dispatch_resume
 因为group没有生效，所以只有q1和q2顺序执行

 */
- (void)DispatchSuspendSelector{
    dispatch_queue_t queue1 = dispatch_queue_create("com.yier.sumup.queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("com.yier.sumup.queue2", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t group = dispatch_group_create();
    
    NSLog(@"1");
    
    //✅完成任务 1和2顺序不确定
    dispatch_async(queue1, ^{
        NSLog(@"任务 1 ： queue 1...");
        [NSThread sleepForTimeInterval:3.f];
        NSLog(@"✅完成任务 1");
    });
    
    dispatch_async(queue2, ^{
        NSLog(@"任务 1 ： queue 2...");
        [NSThread sleepForTimeInterval:3.f];
        NSLog(@"✅完成任务 2");
    });
    
    NSLog(@"2");
    dispatch_group_async(group, queue1, ^{
        NSLog(@"🚫正在暂停 1");
        dispatch_suspend(queue1);
    });
    dispatch_group_async(group, queue2, ^{
        NSLog(@"🚫正在暂停 2");
        dispatch_suspend(queue2);
    });

    NSLog(@"3");
    //当前线程暂停，等待group执行完成，再往后执行
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"＝＝＝＝＝＝＝等待两个queue完成, 再往下进行...");
    dispatch_async(queue1, ^{
        NSLog(@"任务 2 ： queue 1");
    });
    dispatch_async(queue2, ^{
        NSLog(@"任务 2 ： queue 2");
    });
    NSLog(@"🔴为什么这个NSLog会在上面两个NSLog之前打印❓❓答：dispatch_suspend的作用‼️");
    
    NSLog(@"4");
    dispatch_resume(queue1);
    dispatch_resume(queue2);
}

/**
 当前的资源数量大于0，表示信号量处于触发。
 等于0，表示资源已经耗尽，信号量处于等待的状态。
 
 在对信号量调用等待函数时，等待函数会检查信号量的当前资源计数，如果大于0（即信号量处于触发状态），减1后返回让调用线程继续执行。一个线程可以多次调用等待函数来减小信号量。
 
 当一个信号量被通知，其计数会增加。
 当一个线程在一个信号量等待时候，线程会处于阻塞，直到计数器大于0，然后线程会减少这个计数
 
 GCD提供三个函数对semaphore进行操作
 
 dispatch_semaphore_create 创建semaphore,代表信号总量。
 dispatch_semaphore_wait 等待semaphore，当信号量总数少于0，就会处于等待状态（因为本身为0，执行wait就会-1，执行等待）
 dispatch_semaphore_signal 通知semaphore，信号量+1。当信号量>= 0 会执行wait之后的代码.
 */
- (void)SemaphoreAsyncSelector{
    dispatch_queue_t queue = dispatch_get_global_queue ( DISPATCH_QUEUE_PRIORITY_DEFAULT , 0 ) ;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1) ;
    
    NSMutableArray *array = [[NSMutableArray alloc ] init];
    
    for (NSInteger i = 0; i < 10; i++) {
        dispatch_async(queue, ^ {
            //第一次过来为1，-1之后为0.信号量处于未触发的状态，所以直接打印了
            dispatch_semaphore_wait(semaphore , DISPATCH_TIME_FOREVER);
            [array addObject:[NSNumber numberWithInteger:i]];
            NSLog(@"add");
            //+1
            dispatch_semaphore_signal(semaphore) ;
        });
    }
    
    NSLog(@"arr:%@",array);
}

- (void)SemaphoreSyncSelector{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT , 0);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0) ;
    NSMutableArray *array = [[NSMutableArray alloc ] init];
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i++ ) {
            [array addObject:[NSNumber numberWithInteger:i]];
        }
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore , DISPATCH_TIME_FOREVER);
    NSLog(@"arr:%@",array);
}

#pragma mark - dispatchSetTargetQueueDemo

/**
 dispatch_set_target_queue 函数有两个作用：第一，变更队列的执行优先级；第二，目标队列可以成为原队列的执行阶层。
 
 第一个参数是要执行变更的队列（不能指定主队列和全局队列）
 第二个参数是目标队列（指定全局队列）
 
 适用场景：
 一般都是把一个任务放到一个串行的queue中，如果这个任务被拆分了，被放置到多个串行的queue中，但实际还是需要这个任务同步执行，那么就会有问题，因为多个串行queue之间是并行的。这时候dispatch_set_target_queue将起到作用。
 */
- (void)dispatchSetTargetQueueDemo{
    //dispatch_queue_create默认优先级是default
    dispatch_queue_t targetQueue = dispatch_queue_create("com.yier.sumup.targetQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t serialQueue = dispatch_queue_create("com.yier.sumup.serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.yier.sumup.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    //serialQueue变成串行
    dispatch_set_target_queue(serialQueue, targetQueue);
    //concurrentQueue变成串行
    dispatch_set_target_queue(concurrentQueue, targetQueue);
    
    dispatch_async(serialQueue, ^{
        NSLog(@"1");
        [NSThread sleepForTimeInterval:3.f];
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"2");
        [NSThread sleepForTimeInterval:2.f];
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"3");
        [NSThread sleepForTimeInterval:1.f];
    });
}

#pragma mark - dispatchBarrierAsyncDemo

/**
 防止文件读写冲突，可以创建一个串行队列，操作都在这个队列中进行，没有更新数据读用并行，写用串行。
 
 同步栅栏函数dispatch_barrier_sync（在主线程中执行）：前面的任务执行完毕才会来到这里，但是同步栅栏函数会堵塞线程，影响后面的任务执行
 异步栅栏函数dispatch_barrier_async：前面的任务执行完毕才会来到这里

 作用：栅栏函数最直接的作用就是 控制任务执行顺序，使同步执行

 注意：
 1、栅栏函数只能控制同一并发队列
2、 同步栅栏添加进入队列的时候，当前线程会被锁死，直到同步栅栏之前的任务和同步栅栏任务本身执行完毕时，当前线程才会打开然后继续执行下一句代码
 
 因此，在使用栅栏函数时,使用自定义队列才有意义:
 
 如果栅栏函数中使用全局队列，运行会崩溃，原因是系统也在用全局并发队列，使用栅栏同时会拦截系统的，所以会崩溃
 如果将自定义并发队列改为串行队列，即serial ，串行队列本身就是有序同步 此时加栅栏，会浪费性能
 */
-  (void)dispatchBarrierAsyncDemo{
    dispatch_queue_t dataQueue = dispatch_queue_create("com.yier.sumup.dataqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"read data 1");
    });
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 2");
    });
    //等待前面的都完成，在执行barrier后面的
    dispatch_barrier_async(dataQueue, ^{
        NSLog(@"write data 1");
        [NSThread sleepForTimeInterval:1];
    });
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:1.f];
        NSLog(@"read data 3");
    });
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 4");
    });
}

#pragma mark - dispatchApplyDemo

/**
 这里有个需要注意的是，dispatch_apply这个是会阻塞主线程的。这个log打印会在dispatch_apply都结束后才开始执行，但是使用dispatch_async包一下就不会阻塞了。
 */
- (void)dispatchApplyDemo{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.yier.sumup.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(10, concurrentQueue, ^(size_t i) {
        NSLog(@"dispatchApplyDemoLog1 --- %zu",i);
    });
    NSLog(@"dispatchApplyDemo --- end1");
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_apply(10, concurrentQueue, ^(size_t i) {
            NSLog(@"dispatchApplyDemoLog2 --- %zu",i);
        });
    });
    NSLog(@"dispatchApplyDemo --- end2");
    dispatch_barrier_async(concurrentQueue, ^{
        NSLog(@"拦截");
    });
    
    //有问题的情况，可能会引起线程爆炸和死锁
    for (int i = 0; i < 20 ; i++) {
        dispatch_async(concurrentQueue, ^{
            NSLog(@"wrong %d",i);
            //do something hard
        });
    }

    //会优化很多，能够利用GCD管理
    dispatch_apply(20, concurrentQueue, ^(size_t i){
        NSLog(@"correct %zu",i);
        //do something hard
    });
}

#pragma mark - GCDBlock

#pragma mark - dispatchCreateBlockDemo

/**
 QOS_CLASS_USER_INTERACTIVE：user interactive 等级表示任务需要被立即执行，用来在响应事件之后更新 UI，来提供好的用户体验。这个等级最好保持小规模。
 QOS_CLASS_USER_INITIATED：user initiated 等级表示任务由 UI 发起异步执行。适用场景是需要及时结果同时又可以继续交互的时候。
 QOS_CLASS_DEFAULT：default 默认优先级
 QOS_CLASS_UTILITY：utility 等级表示需要长时间运行的任务，伴有用户可见进度指示器。经常会用来做计算，I/O，网络，持续的数据填充等任务。这个任务节能。
 QOS_CLASS_BACKGROUND：background 等级表示用户不会察觉的任务，使用它来处理预加载，或者不需要用户交互和对时间不敏感的任务。
 QOS_CLASS_UNSPECIFIED：unspecified 未指明
 
 dispatch_block_create_with_qos_class第三个参数relative_priority指QoS类中的相对优先级。此值是与给定类支持的最大计划程序优先级的负偏移量。传递大于零或小于-15的值将导致返回空值。
 */
- (void)dispatchCreateBlockDemo{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.yier.sumup.concurrentqueue",DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"run block");
    });
    dispatch_async(concurrentQueue, block);
    dispatch_block_t qosBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, 0, ^{
        NSLog(@"run qos block");
    });
    dispatch_async(concurrentQueue, qosBlock);
}

#pragma mark - dispatchBlockWaitDemo
- (void)dispatchBlockWaitDemo{
    dispatch_queue_t serialQueue = dispatch_queue_create("com.yier.sumup.serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"star");
        [NSThread sleepForTimeInterval:5.f];
        NSLog(@"end");
    });
    dispatch_async(serialQueue, block);
    //设置DISPATCH_TIME_FOREVER会一直等到前面任务都完成
    dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
    NSLog(@"ok, now can go on");
}

#pragma mark - dispatchBlockNotifyDemo
- (void)dispatchBlockNotifyDemo{
    dispatch_queue_t serialQueue = dispatch_queue_create("com.yier.sumup.serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"first block start");
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"first block end");
    });
    dispatch_async(serialQueue, firstBlock);
    dispatch_block_t secondBlock = dispatch_block_create(0, ^{
        NSLog(@"second block run");
    });
    //first block执行完才在serial queue中执行second block
    dispatch_block_notify(firstBlock, serialQueue, secondBlock);
}

#pragma mark - dispatchBlockCancelDemo

/**
 dispatch_block_cancel(iOS8+)
 */
- (void)dispatchBlockCancelDemo{
    dispatch_queue_t serialQueue = dispatch_queue_create("com.yier.sumup.serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"first block start");
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"first block end");
    });
    dispatch_block_t secondBlock = dispatch_block_create(0, ^{
        NSLog(@"second block run");
    });
    dispatch_async(serialQueue, firstBlock);
    dispatch_async(serialQueue, secondBlock);
    //取消secondBlock
    dispatch_block_cancel(secondBlock);
}

#pragma mark - dispatchGroupWaitDemo

/**
 dispatch_group_wait
 */
- (void)dispatchGroupWaitDemo{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.yier.sumup.concurrentqueue",DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    //在group中添加队列的block
    dispatch_group_async(group, concurrentQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"1");
        NSLog(@"%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"2");
        NSLog(@"%@",[NSThread currentThread]);
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"can continue");
}

#pragma mark - GCD错误使用范例

/**
 dispatch_sync: 同步执行提交block到指定队列，直到block完成再返回
 1、必须等待当前语句执行完毕，才会执行下一条语句
 2、不会开启线程|即不具备开启新线程的能力
 3、在当前线程中执行block任务
 
 dispatch_async:
 1、不用等待当前语句执行完毕，就可以执行下一条语句
 2、会开启线程执行block任务，即具备开启新线程的能力（但并不一定开启新线程，这个与任务所指定的队列类型有关）
 3、异步是多线程的代名词
 
 mainqueue：主队列中的任务,都会放到主线程中执行，如果主队列发现当前主线程有任务在执行,那么主队列会暂停调度队列中的任务,直到主线程空闲为止
 死锁: dispatch_sync 底层是同步栅栏函数，会阻塞线程，影响后面任务执行。当前等待的和正在执行的是同一个队列时，即判断线程ID是否相等，如果相等，则会造成死锁
  */

/*
mainThread：因为同步函数的原因，阻塞主线程执行，需要等待提交block函数到主队列并执行block
mainqueue：主队列收到block之后，发现主线程有任务(比如主线程的runloop会处理各种消息)，因此暂停调度并挂起，等主线程先执行
*/
- (void)deadLockCase1{
    //[NSOperationQueue currentQueue] 为 mainQueue
    NSLog(@"1");
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
}

/**
 3会等2，因为2在全局并行队列里，不需要等待3，这样2执行完回到主队列，3就开始执行
 */
- (void)deadLockCase2{
    NSLog(@"1");
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
}

- (void)deadLockCase3{
    dispatch_queue_t serialQueue = dispatch_queue_create("com.yier.sumup.serialqueue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1");
    dispatch_async(serialQueue, ^{
        NSLog(@"2");
        //串行队列里面同步一个串行队列就会死锁
        dispatch_sync(serialQueue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

- (void)deadLockCase4{
    NSLog(@"1");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2");
        //将同步的串行队列放到另外一个线程就能够解决
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

/**
 4、1无法确定顺序，回到主线程被while卡住，3、2无法打印
 */
- (void)deadLockCase5{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1");
        //回到主线程发现死循环后面就没法执行了
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"2");
        });
        NSLog(@"3");
    });
    NSLog(@"4");
    //死循环
    while (1) {
        //
    }
}

#pragma mark - 下载图片
- (void)downloadImgSelector{
    if (self.downloadImg) {
        [self.downloadImg removeFromSuperview];
        self.downloadImg = nil;
    }else{
        self.downloadImg = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 200, 100)];
        self.downloadImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.downloadImg];
        
        NSURL *url1 = [NSURL URLWithString:@"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ffcaeded792e4372a980c098d9f35c53~tplv-k3u1fbpfcp-watermark.image"];
        @weakify(self);
        [self.downloadImg sd_setImageWithURL:url1 placeholderImage:nil options:SDWebImageProgressiveLoad progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            @strongify(self);
            NSLog(@"%f",receivedSize/(CGFloat)expectedSize);
            [self changeAlpha:receivedSize/(CGFloat)expectedSize];
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        }];
        
        [NSThread detachNewThreadSelector:@selector(prefetcher) toTarget:self withObject:nil];
    }
}


- (void)prefetcher{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("prefetcher", DISPATCH_QUEUE_SERIAL);
    
    NSURL * url1 = [NSURL URLWithString:@"https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4b2fb8ec4ef8446997e927e4f9f7516a~tplv-k3u1fbpfcp-watermark.image"];
    
    NSURL *url2 = [NSURL URLWithString:@"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5dd50ea1022e4528948ead3079056e92~tplv-k3u1fbpfcp-watermark.image"];
    
    dispatch_group_enter(group);
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url1 options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"%f",receivedSize/(CGFloat)expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        [[SDImageCache sharedImageCache] storeImageDataToDisk:data forKey:url1.absoluteString];
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url2 options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"%f",receivedSize/(CGFloat)expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        [[SDImageCache sharedImageCache] storeImageDataToDisk:data forKey:url1.absoluteString];
        dispatch_group_leave(group);
    }];
    
    /*
     long dispatch_group_wait(dispatch_group_t group, dispatch_time_t timeout)

     group：需要等待的调度组
     timeout：等待的超时时间（即等多久）
        - 设置为DISPATCH_TIME_NOW意味着不等待直接判定调度组是否执行完毕
        - 设置为DISPATCH_TIME_FOREVER则会阻塞当前调度组，直到调度组执行完毕


     返回值：为long类型
        - 返回值为0——在指定时间内调度组完成了任务
        - 返回值不为0——在指定时间内调度组没有按时完成任务

     */
    //    long timeout = dispatch_group_wait(group, DISPATCH_TIME_NOW);
    //    long timeout = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    long timeout = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));
    if (timeout == 0) {
        NSLog(@"按时完成任务");
    }else{
        NSLog(@"超时: %ld",timeout);
    }
    
    dispatch_group_notify(group, queue, ^{
        [self performSelectorOnMainThread:@selector(deleteCache) withObject:nil waitUntilDone:YES];
        NSLog(@"until");
    });
}

- (void)deleteCache{
    NSURL * url1 = [NSURL URLWithString:@"https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4b2fb8ec4ef8446997e927e4f9f7516a~tplv-k3u1fbpfcp-watermark.image"];
    [SDImageCache.sharedImageCache diskImageExistsWithKey:url1.absoluteString completion:^(BOOL isInCache) {
        NSLog(@"url1的图片存在");
    }];
    
    NSLog(@"delete cache");
    [SDImageCache.sharedImageCache clearDiskOnCompletion:nil];
}

- (void)changeAlpha:(CGFloat)alpha{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadImg.alpha = alpha;
    });
}


/* enter level，enter执行--操作，level执行++操作，notify只要检测到是0就执行。enter和level个数必须相同，且level必须在enter之后
 因此，notify并不一定是在所有enter-level之后，只要state=0，就会触发，比如下面这个例子
 */
- (void)enterLevelSelector{
    dispatch_queue_t queue1 = dispatch_queue_create("com.yier.sumup.queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("com.yier.sumup.queue2", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_async(queue1, ^{
        NSLog(@"下载图片一");
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"更新UI");
    });
    
    [NSThread sleepForTimeInterval:1];
    dispatch_group_enter(group);
    dispatch_async(queue2, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"下载图片二");
        dispatch_group_leave(group);
    });
    
}

/*
 dispatch_group_async 效果等同于enter dispatch_async level,其底层的实现就是enter-leave
 */
- (void)groupAsyncSelector{
    dispatch_queue_t queue1 = dispatch_queue_create("com.yier.sumup.queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("com.yier.sumup.queue2", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue1, ^{
//        [NSThread sleepForTimeInterval:3];
        NSLog(@"下载图片一");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"更新UI");
    });
    
    [NSThread sleepForTimeInterval:1];
    dispatch_group_async(group,queue2, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"下载图片二");
    });
}

@end
