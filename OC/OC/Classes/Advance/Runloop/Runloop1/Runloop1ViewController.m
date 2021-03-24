//
//  Runloop1ViewController.m
//  OC
//
//  Created by yier on 2019/4/7.
//  Copyright © 2019 yier. All rights reserved.
//

#import "Runloop1ViewController.h"
#import "HLThread.h"

@interface Runloop1ViewController ()<NSURLConnectionDataDelegate>
@property (strong, nonatomic)   HLThread            *subThread;  /**< 子线程 */
@property(nonatomic, strong) NSURLConnection *connection;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;

@end

@implementation Runloop1ViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //打印与主线程关联的RunLoop，可以查看MainRunLoop中的modes，还可以看到commonItems和各个mode中的items
    CFRunLoopRef runLoopRef = CFRunLoopGetMain();
    CFArrayRef modes = CFRunLoopCopyAllModes(runLoopRef);
    NSLog(@"MainRunLoop中的modes:%@",modes);
    NSLog(@"MainRunLoop对象：%@",runLoopRef);
    
    // 1.测试线程的销毁
    [self threadTest];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(subThreadOpetion) onThread:self.subThread withObject:nil waitUntilDone:NO];
}

- (void)threadTest
{
    HLThread *subThread = [[HLThread alloc] initWithTarget:self selector:@selector(subThreadEntryPoint) object:nil];
    [subThread setName:@"HLThread"];
    [subThread start];
    self.subThread = subThread;
}

- (void)subThreadEntryPoint
{
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        //如果注释了下面这一行，子线程中的任务并不能正常执行，machport是为了让这个线程保活，用移除machport的方式，并不能关掉这个线程，需要手动关掉，比如把线程保存成属性，在不需要这个线程的时候设置=nil就可以了
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        NSLog(@"启动RunLoop前--%@",runLoop.currentMode);
        NSLog(@"currentRunLoop:%@",[NSRunLoop currentRunLoop]);
        
        // 打印当前RunLoop中的Modes
        //    CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
        //    CFArrayRef modes = CFRunLoopCopyAllModes(runLoopRef);
        //    NSLog(@"打印当前RunLoop中的Modes:%@",modes);
        
        [runLoop run];
    }
}

/**
 子线程任务
 */
- (void)subThreadOpetion
{
    NSLog(@"启动RunLoop后--%@",[NSRunLoop currentRunLoop].currentMode);
    NSLog(@"%@----子线程任务开始，延时3秒",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:3.0];
    
    [self download];
    NSLog(@"%@----子线程任务结束",[NSThread currentThread]);
}

/*测试保活的子线程发起请求的情况。这儿如果没有machport保活，也不设置回调队列，那么回调回来就会无法响应。
 因此解决回调有两种方式：
 1、子线程machport保活
 2、增加回调队列
 */
- (void)download{
    if (!self.connection) {
        NSURL *url = [NSURL URLWithString:@"https://tva1.sinaimg.cn/large/008eGmZEly1gous39kl86j31fz0u0ag8.jpg"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2];
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//        [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    }

    [self.connection start];
}

#pragma mark - delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *result = (NSHTTPURLResponse *)response;
    NSLog(@"❌ %zd",result.statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    UIImage *image = [UIImage imageWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadImageView.image = image;
    });
    NSLog(@"当前线程：%@  下载完成：%@",[NSThread currentThread],image);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"❌ %@",error.description);
}

@end
