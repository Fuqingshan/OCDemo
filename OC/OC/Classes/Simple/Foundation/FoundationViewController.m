//
//  FoundationViewController.m
//  OC
//
//  Created by yier on 2019/2/18.
//  Copyright © 2019 yier. All rights reserved.
//

#import "FoundationViewController.h"
#import <objc/message.h>
#import "SubProxy.h"
#import <Network/Network.h>

@interface FoundationViewController ()<UITableViewDataSource,UITableViewDelegate,NSCacheDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSCache *cache;

@end

@implementation FoundationViewController


/**
 load方法会在 initialize方法的调用操作之前、类被加载之后立即被调用。实际上,对于
 以静态方式链接的类(可执行程序的组成部分,调用load方法的操作在调用main()函数
 的操作之前执行。如果load方法是由可选包裹中的类实现的,那么当该包以动态方式被加
 载时load方法就会运行。应非常小心地使用load方法,因为在启动应用过程中它的次序非
 常靠前。尤其是,当该方法被调用时,程序的自动释放池(通常)还不存在,其他类可能还没有加载等。
 
 load方法可以由类实现也可以由分类实现,实际上,一个类中的所有分类都能够实现其本
 身的load方法。 initialize方法永远都不能在分类中重写。
 
 在已经实现的情况下,当类被加载时,load方法会被调用一次。在已经实现的情况下,当
 类收到第一条消息时, initialize方法会被调用一次;如果类没有被使用,那么 initialize
 方法就不会被调用。
 */
+ (void)initialize
{
    if (self == [FoundationViewController class]) {
        
    }
}

+ (void)load{
    
}

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"Foundation";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

#pragma mark - initData
- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"NSObject"
                            ,@"sel":@"NSObjectSelector"
                            }
                        ,@{
                            @"content":@"NSProxy"
                            ,@"sel":@"NSProxySelector"
                            }
                        ,@{
                            @"content":@"NSString"
                            ,@"sel":@"NSStringSelector"
                            }
                        ,@{
                            @"content":@"NSScanner"
                            ,@"sel":@"NSScannerSelector"
                            }
                        ,@{
                            @"content":@"NSDate"
                            ,@"sel":@"NSDateSelector"
                            }
                        ,@{
                            @"content":@"NSValue"
                            ,@"sel":@"NSValueSelector"
                            }
                        ,@{
                            @"content":@"NSNumber"
                            ,@"sel":@"NSNumberSelector"
                            }
                        ,@{
                            @"content":@"NSDecimalNumber"
                            ,@"sel":@"NSDecimalNumberSelector"
                            }
                        ,@{
                            @"content":@"NSCache"
                            ,@"sel":@"NSCacheSelector"
                            }
                        ,@{
                            @"content":@"NSXMLParser"
                            ,@"sel":@"NSXMLParserSelector"
                            }
                        ,@{
                            @"content":@"NSPredicate"
                            ,@"sel":@"NSPredicateSelector"
                            }
                        ,@{
                            @"content":@"NSHost"
                            ,@"sel":@"NSHostSelector"
                            }
                        ,@{
                            @"content":@"NSRegularExpression"
                            ,@"sel":@"NSRegularExpressionSelector"
                            }
                        ,@{
                            @"content":@"NSFileHandle"
                            ,@"sel":@"NSFileHandleSelector"
                            }
                        ,@{
                            @"content":@"NSFileManager"
                            ,@"sel":@"NSFileManagerSelector"
                            }
                        ,@{
                            @"content":@"NSStream"
                            ,@"sel":@"NSStreamSelector"
                            }
                        ,@{
                            @"content":@"NSTask"
                            ,@"sel":@"NSTaskSelector"
                            }
                        ,@{
                            @"content":@"NSOperation"
                            ,@"sel":@"NSOperationSelector"
                            }
                        ,@{
                            @"content":@"NSLock"
                            ,@"sel":@"NSLockSelector"
                            }
                        ,@{
                            @"content":@"NSNotify"
                            ,@"sel":@"NSNotifySelector"
                            }
                        ,@{
                            @"content":@"NSNotificationQueue"
                            ,@"sel":@"NSNotificationQueueSelector"
                            }
                        ,@{
                            @"content":@"NSKeyedArchiver"
                            ,@"sel":@"NSKeyedArchiverSelector"
                            }
                        ,@{
                            @"content":@"NSPropertyListSerialization"
                            ,@"sel":@"NSPropertyListSerializationSelector"
                            }
                        ,@{
                            @"content":@"NSLogv"
                            ,@"sel":@"NSLogvSelector"
                            }
                        ,@{
                            @"content":@"NSRunloop"
                            ,@"sel":@"NSRunloopSelector"
                            }
                        ,@{
                            @"content":@"TryCatch"
                            ,@"sel":@"TryCatchSelector"
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
    ((void(*)(id,SEL))objc_msgSend)(self,sel);
    //有返回值
    //    ((NSString *(*)(id,SEL))objc_msgSend)(self,sel);
}

- (void)NSObjectSelector{
    NSURLProtocol *p = [[NSURLProtocol alloc] init];
    //description 默认实现仅只显示类名
    NSLog(@"%@ %@",[p description],[p debugDescription]);
}


/**
 虽然NSProxy和class NSObject都定义了-forwardInvocation:和-methodSignatureForSelector:，但这两个方法并没有在protocol NSObject中声明；两者对这俩方法的调用逻辑更是完全不同。
 对于class NSObject而言，接收到消息后先去自身的方法列表里找匹配的selector，如果找不到，会沿着继承体系去superclass的方法列表找；如果还找不到，先后会经过+resolveInstanceMethod:和-forwardingTargetForSelector:处理，处理失败后，才会到-methodSignatureForSelector:/-forwardInvocation:进行最后的挣扎。更详细的叙述，详见NSObject的消息转发机制。
 但对于NSProxy，接收unknown selector后，直接回调-methodSignatureForSelector:/-forwardInvocation:，消息转发过程比class NSObject要简单得多。
 */
- (void)NSProxySelector{
    SubProxy *proxy = [SubProxy alloc];
    if ([proxy respondsToSelector:@selector(eat)]) {
        [proxy performSelector:@selector(eat)];
    }
}

- (void)NSStringSelector{
    NSString *greet = @"hello world";
    NSRange range = [greet rangeOfString:@"world"];
    if (range.length != NSNotFound) {
        NSLog(@"%@",NSStringFromRange(range));
    }
    greet = @"hello,,world?";
    range = [greet rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]];
    if (range.length != NSNotFound) {
        NSLog(@"%@",NSStringFromRange(range));
    }
}

/*
 *NSScanner:
 
 charactersToBeSkipped，设置忽略指定字符，默认是空格和回车。
 isAtEnd，是否扫描结束。
 scanLocation，扫描开始的位置
 caseSensitive 是否大小写敏感，YES的话scanner会区分大小写，NO是不区分，默认是NO
 
 */
- (void)NSScannerSelector{
    [self scannerFloat];
    [self scannerFromTo];
    [self scannerABCD];
}

- (void)scannerFloat{
    NSString * aString = @"1.37 3.44 small cases of bananas";
    NSScanner *theScanner = [NSScanner scannerWithString:aString];
    float aFloat = 0.0;
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanFloat:&aFloat];
        theScanner.scanLocation += 1;
        NSLog(@"theScanner.scanLocation:%zd",theScanner.scanLocation);
    }
    NSLog(@"aFloat __ %f",aFloat);
}

- (void)scannerFromTo{
    NSString *string = @" a string from charater A  to and from  scanner  to for test";
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    NSMutableArray *muArr = [NSMutableArray array];
    while ([scanner isAtEnd] == NO) {
        NSString *textStr = nil;
        //找到截取的开始位置
        [scanner scanUpToString:@"from" intoString:nil];
        //找到截取的结束位置
        [scanner scanUpToString:@"to" intoString:&textStr];
        if (textStr.length != 0) {
            [muArr addObject:textStr];
        }
    }
    NSLog(@"%@",muArr);
}

- (void)scannerABCD{
    NSString *test = @"AABBTCCDD";
    NSScanner *scanner = [NSScanner scannerWithString:test];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"T"];
    scanner.charactersToBeSkipped = set;
    NSCharacterSet *set2 = [NSCharacterSet characterSetWithCharactersInString:@"ABCD"];
    NSString *str;
    //scanner从0开始，扫描到之后scanLocation会自动增加，如果字符串变成“1AABBTCCDD”，前面是数字这种，会导致第一次扫描找不到，scanLocation一直是0，导致死循环
    while (![scanner isAtEnd]) {
        [scanner scanCharactersFromSet:set2 intoString:&str];
        NSLog(@"%@",str);
        //scanner[1343:108886] AABB
        //scanner[1343:108886] CCDD
    }
}

- (void)NSDateSelector{
    NSString *dateStr = [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLog(@"date --- %@",dateStr);
}

- (void)NSValueSelector{
    int ten = 10;
    int *tenPtr = &ten;
    
    NSValue *myInt = [NSValue value:&tenPtr withObjCType:@encode(int *)];
    NSLog(@"%@",myInt);
}

- (void)NSNumberSelector{
    NSNumber *num = [NSNumber numberWithDouble:1.234];
    NSLog(@"%@",num.stringValue);
}

- (void)NSDecimalNumberSelector{
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:@"2.13"];
    NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:@"7.567"];
    NSDecimalNumber *num3 = [num1 decimalNumberByAdding:num2];
    NSLog(@"%@",num3);
}

- (void)NSCacheSelector{
    if (!self.cache) {
        self.cache = [[NSCache alloc] init];
        // 缓存中总共可以存储多少条
        self.cache.countLimit = 5;
        // 缓存的数据总量为多少
        self.cache.totalCostLimit = 1024 * 5;
        
        [[[self rac_signalForSelector:@selector(cache:willEvictObject:) fromProtocol:@protocol(NSCacheDelegate)]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(RACTuple * _Nullable x) {
             NSLog(@"缓存移除  %@",x);
         }];
        //代理需要写在订阅的后面，否则无法订阅
        self.cache.delegate = self;
    }
    
    //添加缓存数据
    for (int i = 0; i < 10; i++) {
        [self.cache setObject:[NSString stringWithFormat:@"hello %d",i] forKey:[NSString stringWithFormat:@"h%d",i]];
        NSLog(@"添加 %@",[NSString stringWithFormat:@"hello %d",i]);
    }
    
    //输出缓存中的数据，最多缓存5条，所以部分输出null
    for (int i = 0; i < 10; i++) {
        NSLog(@"%@",[self.cache objectForKey:[NSString stringWithFormat:@"h%d",i]]);
    }
    
    //模拟器模拟内存out
    @weakify(self);
    [[[self rac_signalForSelector:@selector(didReceiveMemoryWarning)] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RACTuple * _Nullable x) {
       @strongify(self);
        //当收到内存警告之后,清除数据之后,NSCache缓存池中所有的数据都会为空!
        [self.cache removeAllObjects];
        //输出缓存中的数据
        for (int i = 0; i < 10; i++) {
            NSLog(@"%@",[self.cache objectForKey:[NSString stringWithFormat:@"h%d",i]]);
        }
    }];
}

#pragma mark - XML 解析
- (void)NSXMLParserSelector{
    
}

#pragma mark - 谓词
- (void)NSPredicateSelector{
    NSArray *arr = @[@(1),@(2),@(3)];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF > 1"];
    NSLog(@"%@",[arr filteredArrayUsingPredicate:p]);
}

- (void)NSHostSelector{
    NSNetService *a;
    NSLog(@"%@",a);
    
    NSString *name=[[NSProcessInfo processInfo] processName];
    NSLog(@"name:%@  hostName:%@",name,[NSProcessInfo processInfo].hostName);
}

#pragma mark - 正则表达式和文本处理
- (void)NSRegularExpressionSelector{
    NSError *error;
    NSRegularExpression *regex =[NSRegularExpression
                                regularExpressionWithPattern:@"World"
                                options: NSRegularExpressionCaseInsensitive
                                error: &error];
    NSString *greeting=@"Hello, World";
    NSTextCheckingResult *match= [regex firstMatchInString: greeting
                                                              options: 0
                                                     range: NSMakeRange(0, [greeting length])];
   NSRange range=[match range];
    NSLog(@"Match begins at %@ in string",NSStringFromRange(range));
}

- (void)NSFileHandleSelector{
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *myFile =[NSString stringWithFormat: @"%@/%@", tmpDir,@"Example.txt"];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath: myFile];
    if (fileHandle){
        NSData *fileData =[fileHandle readDataToEndOfFile];
        NSLog(@"%lu bytes read from file %@",[fileData length], myFile);
    }
}

- (void)NSFileManagerSelector{
    NSFileManager *filemgr= [NSFileManager defaultManager];
    NSString *currentPath=[filemgr currentDirectoryPath];
    NSError *error;
    NSArray *contents =[filemgr contentsOfDirectoryAtPath: currentPath error: &error];
    NSLog(@"Contents %@", contents);
    if (contents){
        NSString *file =[NSString stringWithFormat: @"%@/%@", currentPath, contents[0]];
        if ([filemgr isExecutableFileAtPath: file]){
            NSLog(@"%@ is executable",file);
        }
    }
}


/**
 NSSteam、NSInputStream、NSoutputStream
 */
- (void)NSStreamSelector{
    NSString *currentPath= [[NSFileManager defaultManager] currentDirectoryPath];
    NSString *myFile = [NSString stringWithFormat: @"%@/%@",currentPath,@"Example. txt"];
    NSInputStream *ins =[NSInputStream inputStreamWithFileAtPath: myFile];
    [ins open];
    if (ins && [ins hasBytesAvailable]){
      uint8_t buffer [1024];
      NSUInteger len =[ins read: buffer maxLength:1024];
      NSLog(@"Bytes read =%lu", len);
    }
}

#pragma mark - 进程与线程

/**
 NSTask类和NSThread类用于管理进程和线程。使用NSTask类可以在 Objective-C运行时系统中
 创建和管理进程。 NSTask实例作为独立进程进行操作,它不与其他进程共享内存,包括创建它的
 进程。一个 NSTask对象只能运行一次,而且其环境需要在它运行之前配置好。
 */

/*
 进程间通信:
 方式一：通道（NSPipe类可以封装管道(pipe),管道是用于在进程间进行通信的单向信道。）
 
 NSTask *task= [[NSTask alloc] init];
 [task setLaunchPath: @/bin/ls"];
 NSPipe * outPipe = [NSPipe pipe];
 [task setStandardOutput: outPipe];
 [task launch];
 NSData *output= [LoutPipe fileHandleForReading] readDataToEndOfFile];
 NSString *lsout= [[NSString alloc] initwithData: output
 encoding: NSUTF8String Encoding];
 NSLog(@/bin/ls output: \n%@", Isout);
 
 方式二：通过端口
 NSPort、 NSMachPort、 NSMessagePort和 NSSocketport类为进程和线程间通信提供了底层机制
 (通常通过 NSPortMessage对象)
 NSPort类是一个抽象类,它含有多个方法,使用这些方法可以创建和初始化端口、创建端口
 连接、设置端口信息和监听端口。 NSMachPort、 NSMessagePort和 NSSocketport类是 NSPort类的具
 体子类,用于设置通信端口的类型。 NSMachPort类和 NSMessagePort类仅允许进行本地通信(即在
 同一台设备上)。此外, NSMachPort类用于Mach端口(OSx中的基础通信端口)。 NSSocketPort
 类既允许进行本地通信,也允许进行远程通信,但是当使用它进行本地通信时可能效率不如专门
 用于本地通信的类。在创建 NSConnection实例时(使用 initwithReceiveport: sendPort:方法),可
 以将端口实例用作参数。还可以通过 NSPort类的 scheduleInRunLoop: forMode:方法,向运行循环
 中添加端口。
 因为端口是非常底层的进程间通信机制,所以在实现应用间通信时,应在尽可能地使用分布
 式对象,而只在必要时使用 NSPort对象。此外,结束对端口对象的操作后,必须使用 NSPort类的
 invalidate方法显式地使该对象失效。
 NSSocketport类和 NSPortMessage类只能在OSx平台上使用
 
 */
- (void)NSTaskSelector{
    [NSThread detachNewThreadSelector:@selector(executeThread) toTarget:self withObject:nil];
}

- (void)executeThread{
    
}

#pragma 队列
/**
 NSOperation、 NSBlockoperation和 NSInvocationoperation类用于管理一个或多个操作、代码
 以及单个任务关联数据的并行执行过程。操作队列是指提供并行执行任务功能的 Objective-C对
 象。每个任务(即操作)都定义了需要执行的程序和与之相关的数据,而且会被封装在块对象或
 NSOperation类的具体子类中。 NSOperation是一个抽象类,用于封装单个任务的代码和相关数据。
 在处理非并行任务时,具体子类通常只需重写主要方法。在处理并行任务时,至少必须重写 start、
 is Concurrent、 isExecuting和 fInished方法。
 */
- (void)NSOperationSelector{
    
}

#pragma mark - 锁

/**
 使用NSLock、 NSDistributedLock、 NSConditionlock和 NSRecursivelock类可以为同步执行的
 代码创建锁。 NSLock类为并行编程方式实现了一个基本的互斥锁。该类遵守 NSLocking协议,因此
 实现了用于获取和释放锁的1ock方法和 unlock方法。
 NSDistributedlock类定义了可由多台主机上的多个应用程序使用的锁,该锁可以控制对共享
 资源的访问。
 NSConditionlock类定义了只能在特定条件下获取和释放的锁。
 NSRecursivelock类定义了在不导致死锁的前提下,可由同一线程使用多次的锁。该锁会记
 录自身被使用的次数,在释放该锁前必须先调用对应的方法解锁对象,以实现锁定和解锁操作
 的平衡。
 */
- (void)NSLockSelector{
}

#pragma mark - 通知
- (void)NSNotifySelector{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AAA:) name:@"NSNotifySelector" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NSNotifySelector" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NSNotifySelector" object:nil];
}

- (void)AAA:(NSNotification *)notify{
    NSLog(@"AAA");
}


/**
 NSNotificationoueue类含有两个发布通知的方法。使用enqueueNotification: postingstyle:
 coalesceMask: forModes:方法可以设置发布样式、合并选项和支持的发布通知运行模式。可使用
 下列常数定义合并选项
  NSNotificationNoCoalescing:不合并通知,记录所有通知。
  NSNotificationCoalescingOnName:合并同名的通知,即仅记录其中一条通知。
  NSNotificationCoalescingOn Sender:合并来自同一发送者的通知,即仅记录其中一条通
 知
 
 发布样式定义了将通知添加到队列中的交互模式(同步异步、在空闲时立刻)可使用下面
 的常量设置这些选项
  NSPostASAP:当前的运行循环结束时,立刻以异步方式发布通知。
  NSPostwhenIdle:当运行循环等待输入数据或计时器事件时,以异步方式发布通知。
  NSPostNow:在合并后立刻发布队列中的通知,提供高效的同步行为。这类行为不需要依赖运行循环。
 */
- (void)NSNotificationQueueSelector{
    NSNotificationCenter *notifier = [NSNotificationCenter defaultCenter];
    NSNotificationQueue *queue = [[NSNotificationQueue alloc] initWithNotificationCenter: notifier];
    NSString *nName = @"ApplicationDidHandleGreetingNotification";
    NSNotification *notif = [NSNotification notificationWithName:nName
                                                          object: @"Hello, World! "];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BBB:) name:nName object:nil];

    
  
    
    //发送
    [queue
      enqueueNotification: notif
      postingStyle: NSPostNow
      coalesceMask: NSNotificationCoalescingOnName
     forModes: nil];
    
    //移除
    [queue
      dequeueNotificationsMatching: notif
      coalesceMask: NSNotificationNoCoalescing];
}

- (void)BBB:(NSNotification *)notify{
    NSLog(@"BBB");
}

#pragma 归档与序列化
- (void)NSKeyedArchiverSelector{
    RealProxyHandler *handler = [[RealProxyHandler alloc] init];
    handler.name = @"123code";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDir = paths.firstObject;
    NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"archives"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:logsDirectory]) {
      BOOL create =  [[NSFileManager defaultManager] createDirectoryAtPath:logsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (!create) {
            return;
        }
    }
    NSString *archivePath = [logsDirectory stringByAppendingPathComponent: @"archive"];
    BOOL result = [NSKeyedArchiver archiveRootObject:handler toFile:archivePath];
    if (result) {
        NSLog(@"归档成功");
    }
    
    RealProxyHandler *unhandler = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    if (unhandler) {
        NSLog(@"解码成功:%@",unhandler.name);
    }
}

/**
 NSPropertyListOpenStepFormat:传统的ASCI码属性列表格式。
 NSPropertyListXMLFormat v10:XM属性列表格式。
 NSPropertyListBinary Format v10:二进制属性列表格式
 */
- (void)NSPropertyListSerializationSelector{
    NSError *errorStr;
    NSDictionary *data = @{@"FirstName":@"John",@"LastName":@"Doe"};
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:data
                                                                format: NSPropertyListXMLFormat_v1_0
                                                               options: 0
                                                                 error: &errorStr];
    if (errorStr) {
        NSLog(@"%@",errorStr.domain);
    }
    /*
     NSPropertyListImmutable:返回的属性列表中含有不可变对象。
     NSPropertyListMutableContainers:返回的属性列表中含有可变容器,但其中的元素不
     可变。
     NSPropertyListMutableContainersAndLeaves:返回的属性列表中含有可变的容器和元素。
     format:参数设置了存储属性列表的格式。如果将该参数设置为NULL,表明无须使用格式信息。
     可设置该参数的非NULL值为枚举型的 NSPropertyListFormat类。
     */
    NSDictionary *plist = [NSPropertyListSerialization
                         propertyListWithData:plistData
                         options: NSPropertyListImmutable
                           format:NULL
                         error:&errorStr];
    NSLog(@"%@",plist);
}

/**
 NSLogv
 printArgs(4,@"12",@"32",@"56");  Arguments: 12   32   56   56
 printArgs(2,@"12",@"32",@"56");  Arguments: 12   32
 */
- (void)NSLogvSelector{
    printArgs(2,@"12",@"32",@"56");
}

void printArgs(int numArgs, ...){
    va_list args;
    va_start(args, numArgs);
    va_end (args);
    NSMutableString *format = [[NSMutableString alloc] init];
    [format appendString: @"Arguments: "];
    for(int ii = 0; ii < numArgs; ii++){
        [format appendString:@"%@   "];
    }
    NSLogv(format, args);
}

- (void)NSRunloopSelector{
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    NSURL *url = [NSURL URLWithString:@"https://th.bing.com/th/id/Rd6e52d9ddf702b20e2e6a7e09884e2c7?rik=4O65ogaEGltQGg&riu=http%3a%2f%2fimg95.699pic.com%2fphoto%2f50101%2f2806.jpg_wh860.jpg&ehk=ChEA9l2Os4Rf90br0hRr4xI6u%2foLBl4vtDNCMVIyjAU%3d&risl=&pid=ImgRaw"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    __block BOOL downloadEnd = NO;
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTwoTuple<NSURLResponse *,NSData *> * _Nullable x) {
        RACTupleUnpack(NSURLResponse *response,NSData *data) = x;
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"%@",image);
        downloadEnd = YES;
    }];
    
    while (!downloadEnd
           && [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        NSLog(@"while");
    }

    NSLog(@"end");
}

- (void)TryCatchSelector{
    @try {
        //1
        [self TryCatchSelector2];
    }
    @catch (NSException *exception) {
        //2 --- 这里不能再抛异常
        NSLog(@"二\n%s\n%@", __FUNCTION__, exception);
        //        @throw exception;
    }
    @finally {
        //3
        NSLog(@"三\n我一定会执行");
    }
    //4 --- 这里一定会执行
    NSLog(@"四\ntry");
}

- (void)TryCatchSelector2
{
    @try {
        //5 --- 程序到这里会崩
        NSString *str = @"abc";
        [str substringFromIndex:222];
    }
    @catch (NSException *exception) {
        //6 --- 抛出异常，即由上一级处理
        @throw exception;
        //7
        NSLog(@"七\n%s     \n%@", __FUNCTION__, exception);
    }
    @finally {
        //8
        NSLog(@"八\ntryTwo - 我一定会执行");
    }
    
    // 9 --- 如果抛出异常，那么这段代码则不会执行
    NSLog(@"九\n如果这里抛出异常，那么这段代码则不会执行");
}



@end
