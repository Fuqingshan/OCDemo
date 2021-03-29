//
//  RACSignalViewController.m
//  OC
//
//  Created by yier on 2021/3/29.
//  Copyright © 2021 yier. All rights reserved.
//

#import "RACSignalViewController.h"

#import <objc/message.h>

@interface RACSignalViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation RACSignalViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"冷热信号");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"冷热信号");
}

- (void)initData{
    self.dataSource = @[
                        @{
                            @"content":@"冷信号"
                            ,@"sel":@"RACSignalSelector"
                            }
                        ,@{
                            @"content":@"多播冷转热"
                            ,@"sel":@"RACMulticastConnectionSelector"
                            }
                        ,@{
                            @"content":@"热信号"
                            ,@"sel":@"RACSubjectSelector"
                        }
                        ,@{
                            @"content":@"RACBehaviorSubject"
                            ,@"sel":@"RACBehaviorSubjectSelector"
                        }
                        ,@{
                            @"content":@"ReplaySubject"
                            ,@"sel":@"RACReplaySubjectSelector"
                        }
                        ,@{
                            @"content":@"RACGroupedSignal"
                            ,@"sel":@"RACGroupedSignalSelector"
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

/*
 1、冷信号的发送是被动触发的，只有被订阅之后才会发送信号；热信号的发送是主动的，不受订阅动作的时间点影响
 2、每次订阅冷信号，订阅者都会收到完整且相同的信号序列；订阅热信号，订阅者只会收到订阅动作时候发送的信号序列
 
 在 ReactiveCocoa 中， RACSignal 冷信号，当订阅者对其进行订阅后都会接受到；RACSubject 代表热信号，订阅者接收到多少值取决于它订阅的时间与 RACSubject 发送信号的时机。
 */
- (void)RACSignalSelector{
    __block NSInteger count = 0;
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        count += 1;
        NSLog(@"第%zd调用createSignal",count);
        [subscriber sendNext:@"你的名字"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"xx:%@",x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"xx:%@",x);
    }];
}

#pragma mark - 广播的方式转热信号
/*
 //RACMulticastConnection:用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。
内部由RACSubject实现
 */
- (void)RACMulticastConnectionSelector{
    RACSignal *coldSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"Cold signal be subscribed.");
        
        [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{ [subscriber sendNext:@"A"]; }];
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{ [subscriber sendNext:@"B"]; }];
        [[RACScheduler mainThreadScheduler] afterDelay:5 schedule:^{ [subscriber sendCompleted]; }];
        return nil;
    }];
    
    //冷信号订阅，会接收所有的信号序列
    [coldSignal subscribeNext:^(id x) {
        NSLog(@"coldSIgnal: %@",x);
    }];

    
    //1、创建连接，内部有两个信号，一个是源信号soucesignal，一个是热信号subject
    RACMulticastConnection *multicastConnection = [coldSignal publish];
    //2、获取连接之后的信号，订阅者订阅的是热信号
    RACSignal *hotSignal = multicastConnection.signal;//这儿其实是一个RACSubject
    
    //3、连接,激活信号，触发源信号订阅，打印Cold signal be subscribed
    //还有一个autoconnect，这个返回的信号在第一次被订阅时自动触发连接
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [multicastConnection connect];
    }];
    
    //这儿是不会执行的，只是放入了subject的订阅数组中，只有等connect之后才会订阅源信号soucesignal，内部用shouldConnect记录是否已经订阅了源信号
    //后面的订阅者实际订阅的就是热信号，冷信号只被热信号订阅了一次，实现了一对多
    //延迟2秒connect，subject订阅的是源信号，因此会打印两次
    [hotSignal subscribeNext:^(id x) {
        NSLog(@"hotSignal1：%@.", x);
    }];
    
    //间隔4秒之后订阅，去掉connect延迟的2秒，实际热信号只过去了2秒，也是就是说刚好错了A的发送
    [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
        [hotSignal subscribeNext:^(id x) {
            NSLog(@"hotSignal2：%@.", x);
        }];
    }];
}

/*
 RACSubject 是继承于 RACSignal，同事它有3个子类分别是：RACBehaviorSubject、RACReplaySubject、RACGroupedSignal、
 
 冷信号和热信号本质区别在于是否保持状态，冷信号本身不保持多次订阅发送信号过程的状态，所以每次订阅冷信号就会收到完整的信号序列；相反热信号维持多次订阅的状态，订阅者订阅热信号只会收到订阅动作之后发送的信号值。
 */
- (void)RACSubjectSelector{
    RACSignal *coldSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@0];
        [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{
            [subscriber sendNext:@1];
            [subscriber sendNext:@2];
            [subscriber sendCompleted];
        }];

        return nil;
    }];
    
    RACSubject *subject = [RACSubject subject];
    
    //冷信号的订阅者为subject，第二个参数才是订阅者
    [coldSignal subscribe:subject];

    //如果 subject 的订阅者提前终止了订阅，而 subject 并不能终止对 coldSignal 的订阅。
    //举个栗子：假设有个页面是下载一个巨大的图片展示，coldsignal是一个下载很大图片的request，当用户进去这个下载页，然后发现网络不好，就提前退出了，那么[subject subscribesubscribeNext]就被dispose了，而subject对coldsignal的订阅还没完，还要继续等待请求
    //因此最好直接使用RACMulticastConnection，它的内部用RACSerialDisposable处理了subject和源信号的关系
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"value = %@", x);
    }];
}

#pragma mark - RACBehaviorSubject
/*
 每次被订阅的时候会向订阅者发送最新的信号

 初始化的时候，可以设置第一个最新信号
 */
- (void)RACBehaviorSubjectSelector{
    RACSignal *coldSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"Cold signal be subscribed.");
        
        [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{ [subscriber sendNext:@"A"]; }];
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{ [subscriber sendNext:@"B"]; }];
        [[RACScheduler mainThreadScheduler] afterDelay:5 schedule:^{ [subscriber sendCompleted]; }];
        return nil;
    }];
    
    RACBehaviorSubject *behaviorSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:@"Default"];
    RACMulticastConnection *connection = [coldSignal multicast:behaviorSubject];
    RACSignal *hotSignal = connection.signal;
    
    //打印Default、A、B
    [hotSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    //延迟2秒，此时BehaviorSubject最新值就是A，因此delay会打印delayA、delayB
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [hotSignal subscribeNext:^(id  _Nullable x) {
            NSLog(@"delay：%@", x);
        }];
    }];
        
    [connection connect];
}

#pragma mark - RACReplaySubject
/*
 对于publish实现的hotsignal，如果在connect源信号sendComplete或sendError等导致源信号已经dispose，那么之后subscribe热信号的，将接收不到消息，对于这个问题，可以用ReplySubject
 
 只要不设置ReplySubject的容量，订阅者都能收到完整的序列
 */
- (void)RACReplaySubjectSelector{
    //signal是冷信号，每次订阅都会触发一次createblck中的操作，如果遇到下载图片，那么就会出现下载很多次的情况，这就是副作用
    RACSignal *coldSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"Cold signal be subscribed.");
        
        [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{ [subscriber sendNext:@"A"]; }];
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{ [subscriber sendNext:@"B"]; }];
        [[RACScheduler mainThreadScheduler] afterDelay:5 schedule:^{ [subscriber sendCompleted]; }];
        return nil;
    }];
    
    //reply它的作用是保证signal只被触发一次，然后把sendNext的value存起来，下次再有新的subscriber时，直接发送缓存的数据。
    //内部由RACReplySubject和RACMulticastConnection组合实现，reply调用时已经connect了
    //自己实现replay，replaySubjectWithCapacity的数量表示的是超过这个容量，会把之前的value踢出去
    RACSignal *hotSignal = [coldSignal replay];
    /*
     replay：使用时自动connect、不限制内容数量
     replayLast：使用时自动connect、只记录最后一次
     replayLazily：第一次收到订阅时才connect、不限制内容数量
     */
    
    [hotSignal subscribeNext:^(id x) {
        NSLog(@"hotSignal1：%@.", x);
    }];
    
    [hotSignal subscribeNext:^(id x) {
        NSLog(@"hotSignal2：%@.", x);
    }];
}

#pragma mark - RACGroupedSignal
/*
 RACGroupedSignal相当于RACSubject存储了一个key
 */
- (void)RACGroupedSignalSelector{
    RACSignal *sourceSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@0];
            [subscriber sendNext:@1];
            [subscriber sendNext:@2];
            [subscriber sendNext:@3];
            [subscriber sendNext:@4];
            [subscriber sendCompleted];
            return nil;
        }];
        
        RACSignal *groupSignal = [sourceSignal groupBy:^id<NSCopying> _Nullable(id  _Nullable object) {
            return [object integerValue] > 2 ? @"send" : @"skip";
        } transform:^id _Nullable(id  _Nullable object) {
            return @([object integerValue] * 10);
        }];
        
        RACSignal *filterSignal = [[groupSignal filter:^BOOL(RACGroupedSignal *value) {
            return [(NSString *)value.key isEqualToString:@"send"];
        }] flatten];
        
        [filterSignal subscribeNext:^(id  _Nullable x) {
            NSLog(@"value = %@", x);
        }];
}

@end
