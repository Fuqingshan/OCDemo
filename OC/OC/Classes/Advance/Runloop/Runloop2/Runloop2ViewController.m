//
//  Runloop2ViewController.m
//  OC
//
//  Created by yier on 2019/4/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "Runloop2ViewController.h"

@interface Runloop2ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (assign, nonatomic)   NSInteger             count;  /**< 记数 */

@property (strong, nonatomic)   NSThread            *subThread;  /**< 子线程 */

@end

@implementation Runloop2ViewController

- (void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // timer 测试
    self.count = 0;
    
    //打印与主线程关联的RunLoop，可以查看MainRunLoop中的modes，还可以看到commonItems和各个mode中的items
    CFRunLoopRef runLoopRef = CFRunLoopGetMain();
    CFArrayRef modes = CFRunLoopCopyAllModes(runLoopRef);
    NSLog(@"MainRunLoop中的modes:%@",modes);
    NSLog(@"MainRunLoop对象：%@",runLoopRef);
    
    // 在主线程中创建timer
    //    [self timerTest];
    
    //创建子线程，启动runloop
    [self createThread];
    
}

- (void)createThread
{
    NSThread *subThread = [[NSThread alloc] initWithTarget:self selector:@selector(timerTest) object:nil];
    [subThread start];
    self.subThread = subThread;
}

- (void)timerTest
{
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        NSLog(@"启动RunLoop前--%@",runLoop.currentMode);
        NSLog(@"currentRunLoop:%@",[NSRunLoop currentRunLoop]);
        
        // 第一种写法,改正前
        //    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        //    [timer fire];
        // 第一种写法,改正后
        //    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        //    [timer fire];
        // 第二种写法
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)timerUpdate
{
    NSLog(@"当前线程：%@",[NSThread currentThread]);
    NSLog(@"启动RunLoop后--%@",[NSRunLoop currentRunLoop].currentMode);
    NSLog(@"currentRunLoop:%@",[NSRunLoop currentRunLoop]);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.count ++;
        NSString *timerText = [NSString stringWithFormat:@"计时器:%ld",self.count];
        self.timerLabel.text = timerText;
    });
}

#pragma mark - afterDelay
- (void)createAfterDelayThread{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [thread start];
}

- (void)run {
    @autoreleasepool {
        NSLog(@"current thread = %@", [NSThread currentThread]);
        //这个方法相当于在当前runloop的defaultMode模式下加一个timer，当定时器Delay时间到达时，当前如果处于default模式，且runloop正在跑，则执行@selector
        [self performSelector:@selector(dosomething) withObject:nil afterDelay:1];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort: [NSMachPort port] forMode:NSDefaultRunLoopMode];
        //执行runloop，阻断当前线程1秒钟
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        [self performSelector:@selector(stopThread) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
    }
}

- (void)dosomething{
    NSLog(@"dosomething");
}

- (void)stopThread {
    NSLog(@"stop");
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSThread *thread = [NSThread currentThread];
    [thread cancel];
    [self performSelector:@selector(dosomething) withObject:nil afterDelay:0];
}

@end
