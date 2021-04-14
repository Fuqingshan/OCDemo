//
//  RACNormalViewController.m
//  OC
//
//  Created by yier on 2021/3/29.
//  Copyright © 2021 yier. All rights reserved.
//

#import "RACNormalViewController.h"

#import <objc/message.h>

@interface RACNormalViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property(nonatomic, strong) NSMutableArray *monitorArray;
@property(nonatomic, strong) RACDisposable *dispose;

@property(nonatomic, copy) NSString *oberveString;

@property(nonatomic, copy) NSString *channelTerminalA;
@property(nonatomic, copy) NSString *channelTerminalB;

@end

@implementation RACNormalViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"常见用法");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"常见用法");
}

- (void)initData{
    NSLog(@"%@",self.des);
    
    self.dataSource = @[
                        @{
                            @"content":@"监听数组增加删除"
                            ,@"sel":@"monitorArraySelector"
                            }
                        ,@{
                            @"content":@"消息通知"
                            ,@"sel":@"notifacationSelector"
                        }
                        ,@{
                            @"content":@"TextField常见使用"
                            ,@"sel":@"textFieldSelector"
                        }
                        ,@{
                            @"content":@"delay"
                            ,@"sel":@"delaySelector"
                        }
                        ,@{
                            @"content":@"UIAlertView"
                            ,@"sel":@"alertViewSelector"
                        }
                        ,@{
                            @"content":@"cell防止复用引起的问题"
                            ,@"sel":@"prepareForReuseSignalSelector"
                        }
                        ,@{
                            @"content":@"signalForSelector"
                            ,@"sel":@"signalForSelector"
                        }
                        ,@{
                            @"content":@"signalForSelectorFromProtocol"
                            ,@"sel":@"signalForSelectorFromProtocol"
                        }
                        ,@{
                            @"content":@"RAC宏"
                            ,@"sel":@"RACMacroSelector"
                        }
                        ,@{
                            @"content":@"双向绑定"
                            ,@"sel":@"RACChannelTerminalSelector"
                        }
                        ,@{
                            @"content":@"concat"
                            ,@"sel":@"concatSelector"
                        }
                        ,@{
                            @"content":@"flattenMap"
                            ,@"sel":@"flattenMapSelector"
                        }
                        ,@{
                            @"content":@"map"
                            ,@"sel":@"mapSelector"
                        }
                        ,@{
                            @"content":@"concat"
                            ,@"sel":@"concatSelector"
                        }
                        ,@{
                            @"content":@"then"
                            ,@"sel":@"thenSelector"
                        }
                        ,@{
                            @"content":@"merge"
                            ,@"sel":@"mergeSelector"
                        }
                        ,@{
                            @"content":@"zip"
                            ,@"sel":@"zipSelector"
                        }
                        ,@{
                            @"content":@"combineLatest"
                            ,@"sel":@"combineLatestSelector"
                        }
                        ,@{
                            @"content":@"reduce"
                            ,@"sel":@"reduceSelector"
                        }
                        ,@{
                            @"content":@"other"
                            ,@"sel":@"otherSelector"
                        }
                        ];

    [self.tableView reloadData];
    
    self.oberveString =  @"默认值";
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

#pragma mark - 监听数组
- (void)monitorArraySelector{
    if (!self.monitorArray) {
        self.monitorArray =  [NSMutableArray arrayWithCapacity:0];
        
        //RACObserve(TARGET, KEYPATH)的生命周期持续到self或者target变为nil，因此不用自己加takeUntil
        //需要注意的是，在block中使用时，加上weakself和strongself，因为RACObserve宏总是引用了target
        @weakify(self);
        [RACObserve(self, monitorArray) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            NSLog(@"monitorArray: %@",x);
            
            //下面这样写，就需要加上weak strong，防止循环引用
//            NSLog(@"monitorArray: %@",self.monitorArray);
        }];
    }
    
    //两种写法都可以，还可以采用监听NSMutableArray方法的方式扩展NSMutableArray，详见NSMutableArray+RACLifting
    //方式一
    [[self mutableArrayValueForKey:@keypath(self.monitorArray)] addObject:@"11"];
    [[self mutableArrayValueForKey:@keypath(self.monitorArray)] addObject:@"22"];
    [[self mutableArrayValueForKey:@keypath(self.monitorArray)] addObject:@"33"];
    
    //方式二
    NSMutableArray * array =  [self mutableArrayValueForKey:@keypath(self.monitorArray)];
    [array addObject:@44];
    [array addObject:@55];
    [array addObject:@66];

    [array removeObjectAtIndex:0];
}

#pragma mark - 消息通知
- (void)notifacationSelector{
    /*这样移除是错误的写法
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RACTestNotifacation" object:nil];
     */
    //除了手动dispose，当senderror和sendcomplete的时候，也会终止信号
    if (self.dispose) {
        [self.dispose dispose];
        self.dispose = nil;
    }
    
    //这个需要加takeUntil，因为实现的地方只做了dispose的时候，移除通知，但没有做什么时候dispose
    //注意：如果要使用中途移除通知，不能用removeObserver:name:的方式，因为它是用addObserverForName: object: queue: usingBlock直接加到defaultCenter的，需要拿到初始化时的observe，然后用removeObserver:移除。RAC的方式添加的，没法拿到初始化observe，但是可以拿到dispose，用dispose移除
   self.dispose =  [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"RACTestNotifacation" object:nil]
     takeUntil:self.rac_willDeallocSignal]
    subscribeNext:^(id x) {
        NSLog(@"收到通知，之后执行action");
        //Action
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RACTestNotifacation" object:nil];
}


#pragma mark - TextField
- (void)textFieldSelector{
    //随便举得栗子
    UITextField *t;
    [[[[t rac_textSignal]
      throttle:0.5]
      distinctUntilChanged]
     subscribeNext:^(id x) {
        NSLog(@"---%@",x);
    }];
}

#pragma mark - delay
- (void)delaySelector{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendCompleted];
        
        return  nil;
    }];
        
    //delay需要之后调用subscribeNext才会触发，具体可以看内部实现。
    //底层实际上调用的是dispatch_after
   signal =  [signal delay:5];
    
    [signal subscribeNext:^(id  _Nullable x) {
        
    }];
}

#pragma mark - UIAlertView

- (void)alertViewSelector{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"racalert" delegate:nil cancelButtonTitle:@"否定" otherButtonTitles:@"确定", nil];
    [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber * indexBtn) {
        
        if (indexBtn.integerValue == 0) {
            
            NSLog(@"否定");
        }
        else
        {
            NSLog(@"确定");
        }
    }];
    
    [alert show];
    
}

#pragma mark - cell防止复用引起的问题
- (void)prepareForReuseSignalSelector{
    //RAC给UITableViewCell提供了一个方法：rac_prepareForReuseSignal，它的作用是当Cell即将要被重用时，告诉Cell。
    /*
    [[[cell.cancelButton
       rac_signalForControlEvents:UIControlEventTouchUpInside]
      takeUntil:self.rac_prepareForReuseSignal]
     subscribeNext:^(UIButton *x) {
         // do other things
     }];
     */
}

#pragma mark - 监听方法调用
- (void)signalForSelector{
    [[self rac_signalForSelector:@selector(test)]subscribeNext:^(id x) {
        NSLog(@"当test被调用的时候，执行这一段代码");
    }];
    
    [self test];
}

//这里的rac_liftSelector:withSignals 就是干这件事的，它的意思是当signalA和signalB都至少sendNext过一次，接下来只要其中任意一个signal有了新的内容，doA:withB这个方法就会自动被触发
- (void)test{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [subscriber sendNext:@"A"];
        });
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"B"];
        [subscriber sendNext:@"Another B"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [self rac_liftSelector:@selector(doA:withB:) withSignals:signalA, signalB, nil];
}

- (void)doA:(NSString *)A withB:(NSString *)B
{
    NSLog(@"A:%@ and B:%@", A, B);
}
    
#pragma mark - 监听协议
- (void)signalForSelectorFromProtocol{
    UITextView *textView;
    
    @weakify(self);
    [[[[self rac_signalForSelector:@selector(textViewDidChange:) fromProtocol:@protocol(UITextViewDelegate)]
      takeUntil:self.rac_willDeallocSignal] filter:^BOOL(RACTuple * _Nullable value) {
        @strongify(self);
      //code
        return YES;
    }] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
       //code
    }];
    
    [[[self rac_signalForSelector:@selector(textViewDidEndEditing:) fromProtocol:@protocol(UITextViewDelegate)]
      takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
       //code
    }];
    
    //设置遵循协议的对象要放在rac方法之后，且self并未实现对应协议的方法,在@interface后面也要加上UITextViewDelegate
    textView.delegate = self;
}

#pragma mark - 常规
- (void)RACMacroSelector{
    @weakify(self);
    [RACObserve(self, oberveString) subscribeNext:^(NSString* x) {
        @strongify(self);
        NSLog(@"%@ --- %@", NSStringFromSelector(_cmd),x);
    }];
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //把修改的信号绑定到observeString
    RAC(self, oberveString) = [signalA map:^id(NSString* value) {
        
        if ([value isEqualToString:@"1"]) {
            return @"2";
        }
        return @"";
    }];
}

#pragma mark - 双向绑定，管道
//适合viewmodel和model绑定，只要其中有一个变化，就通知另一个
//常见的场景还有两个输入框，其中一个内容改变另一个必须同步的情况
- (void)RACChannelTerminalSelector{
    //快速创建
    RACChannelTerminal *channelA = RACChannelTo(self, channelTerminalA, @"channelA");
    RACChannelTerminal *channelB = RACChannelTo(self, channelTerminalB, @"channelB");
    
    //相互绑定
    [channelA subscribe:channelB];
    [channelB subscribe:channelA];
    
    //刚订阅时打印的默认值
    [RACObserve(self, channelTerminalA)  subscribeNext:^(NSString* x) {
        NSLog(@"channelTerminalA: %@",x);
    }];
    
    [RACObserve(self, channelTerminalB)  subscribeNext:^(NSString* x) {
        NSLog(@"channelTerminalB: %@",x);
    }];

    //这儿都会打印两次，因为两者同步的数据
    self.channelTerminalA = @"改变A";
    self.channelTerminalB = @"改变B";
}

#pragma mark - flattenMap：把源信号的内容映射成一个新的信号，信号可以是任意类型。 类似：func a<T,U>(_ mapper:T) -> Result<U>
/*
flattenMap使用步骤:
1.传入一个block，block类型是返回值RACStream，参数value
2.参数value就是源信号的内容，拿到源信号的内容做处理
3.包装成RACReturnSignal信号，返回出去。

flattenMap底层实现:
0.flattenMap内部调用bind方法实现的,flattenMap中block的返回值，会作为bind中bindBlock的返回值。
1.当订阅绑定信号，就会生成bindBlock。
2.当源信号发送内容，就会调用bindBlock(value, *stop)
3.调用bindBlock，内部就会调用flattenMap的block，flattenMap的block作用：就是把处理好的数据包装成信号。
4.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
5.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
 */

- (void)flattenMapSelector{
    UITextField *t;
    [[t.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        // block什么时候 : 源信号发出的时候，就会调用这个block。
        // block作用 : 改变源信号的内容。
        // 返回值：绑定信号的内容.
        return [RACSignal return:[NSString stringWithFormat:@"输出:%@",value]];
    }] subscribeNext:^(id  _Nullable x) {
        // 订阅绑定信号，每当源信号发送内容，做完处理，就会调用这个block。
        NSLog(@"%@",x);
    }];
}

#pragma mark - map:把源信号的值映射成一个新的值。 类似：func a<T,U>(_ mapper:T) -> U
/*
 Map使用步骤:
 1.传入一个block,类型是返回对象，参数是value
 2.value就是源信号的内容，直接拿到源信号的内容做处理
 3.把处理好的内容，直接返回就好了，不用包装成信号，返回的值，就是映射的值。

 Map底层实现:
 0.Map底层其实是调用flatternMap,Map中block中的返回的值会作为flatternMap中block中的值。
 1.当订阅绑定信号，就会生成bindBlock。
 3.当源信号发送内容，就会调用bindBlock(value, *stop)
 4.调用bindBlock，内部就会调用flattenMap的block
 5.flattenMap的block内部会调用Map中的block，把Map中的block返回的内容包装成返回的信号。
 5.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
 6.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
 */

- (void)mapSelector{
    UITextField *t;
    [[t.rac_textSignal map:^id(id value) {
           // 当源信号发出，就会调用这个block，修改源信号的内容
           // 返回值：就是处理完源信号的内容。
           return [NSString stringWithFormat:@"输出:%@",value];
   }] subscribeNext:^(id x) {
       NSLog(@"%@",x);
   }];
}

#pragma mark - concat:按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号。
/*concat底层实现:
 1.当拼接信号被订阅，就会调用拼接信号的didSubscribe
 2.didSubscribe中，会先订阅第一个源信号（signalA）
 3.会执行第一个源信号（signalA）的didSubscribe
 4.第一个源信号（signalA）didSubscribe中发送值，就会调用第一个源信号（signalA）订阅者的nextBlock,通过拼接信号的订阅者把值发送出来.
 5第一个源信号（signalA）didSubscribe中发送完成，就会调用第一个源信号（signalA）订阅者的completedBlock,订阅第二个源信号（signalB）这时候才激活（signalB）。
 6.订阅第二个源信号（signalB）,执行第二个源信号（signalB）的didSubscribe
 7.第二个源信号（signalA）didSubscribe中发送值,就会通过拼接信号的订阅者把值发送出来.
 */
- (void)concatSelector{
        RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
             [subscriber sendNext:@1];
            [subscriber sendCompleted];
            return nil;
        }];
        RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@2];
            return nil;
        }];

        // 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活。
        RACSignal *concatSignal = [signalA concat:signalB];

        // 以后只需要面对拼接信号开发。
        // 订阅拼接的信号，不需要单独订阅signalA，signalB
        // 内部会自动订阅。
        // 注意：第一个信号必须发送完成，第二个信号才会被激活
        [concatSignal subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];
}

#pragma mark - then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号。
/*注意使用then，之前信号的值会被忽略掉.
 底层实现：
 1、先过滤掉之前的信号发出的值。
 2、使用concat连接then返回的信号
 */
- (void)thenSelector{
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
             [subscriber sendNext:@1];
             [subscriber sendCompleted];
             return nil;
    }] then:^RACSignal *{
     return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                 [subscriber sendNext:@2];
                 return nil;
                }];
    }] subscribeNext:^(id x) {
         // 只能接收到第二个信号的值，也就是then返回信号的值
         NSLog(@"%@",x);
    }];
}

#pragma mark - merge:把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
/*底层实现：
 1.合并信号被订阅的时候，就会遍历所有信号，并且发出这些信号。
 2.每发出一个信号，这个信号就会被订阅
 3.也就是合并信号一被订阅，就会订阅里面所有的信号。
 4.只要有一个信号被发出就会被监听。
 */
- (void)mergeSelector{
        RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           [subscriber sendNext:@1];
           return nil;
       }];

       RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           [subscriber sendNext:@2];
           return nil;
       }];

       // 合并信号,任何一个信号发送数据，都能监听到.
       RACSignal *mergeSignal = [signalA merge:signalB];
       [mergeSignal subscribeNext:^(id x) {
           NSLog(@"%@",x);
       }];
}

#pragma mark - zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
/*
 底层实现:
 1.定义压缩信号，内部就会自动订阅signalA，signalB
 2.每当signalA或者signalB发出信号，就会判断signalA，signalB有没有发出个信号，有就会把最近发出的信号都包装成元组发出。
 */

- (void)zipSelector{
        RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@1];
            return nil;
        }];

        RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@2];
            return nil;
        }];

        // 压缩信号A，信号B
        RACSignal *zipSignal = [signalA zipWith:signalB];
        [zipSignal subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];
}

#pragma mark - combineLatest:将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
/*
 底层实现：
 1.当组合信号被订阅，内部会自动订阅signalA，signalB,必须两个信号都发出内容，才会被触发。
 2.并且把两个信号组合成元组发出。
 */
- (void)combineLatestSelector{
     RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       [subscriber sendNext:@1];
       return nil;
    }];

    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       [subscriber sendNext:@2];
       return nil;
    }];

    // 把两个信号组合成一个信号,跟zip一样，没什么区别，两种写法都可以
//    RACSignal *combineSignal = [signalA combineLatestWith:signalB];
    RACSignal *combineSignal = [RACSignal combineLatest:@[signalA,signalB]];
    [combineSignal subscribeNext:^(id x) {
       NSLog(@"%@",x);
    }];
}

#pragma mark - reduce聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
/*
底层实现:
1.订阅聚合信号，每次有内容发出，就会执行reduceblcok，把信号内容转换成reduceblcok返回的值。
 */

- (void)reduceSelector{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       [subscriber sendNext:@1];
       return nil;
    }];

    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       [subscriber sendNext:@2];
       return nil;
    }];

    // 聚合
    // 常见的用法，（先组合在聚合）。combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock
    // reduce中的block简介:
    // reduceblcok中的参数，有多少信号组合，reduceblcok就有多少参数，每个参数就是之前信号发出的内容
    // reduceblcok的返回值：聚合信号之后的内容。
    RACSignal *reduceSignal = [RACSignal combineLatest:@[signalA,signalB] reduce:^id(NSNumber *num1 ,NSNumber *num2){
      return [NSString stringWithFormat:@"%@ %@",num1,num2];
    }];

    [reduceSignal subscribeNext:^(id x) {
       NSLog(@"%@",x);
    }];
}

#pragma mark - 其他附加条件
- (void)otherSelector{
    /*
     filter:过滤信号，使用它可以获取满足条件的信号
     ignore:忽略完某些值的信号.
     distinctUntilChanged:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
     take:从开始一共取N次的信号
     takeLast:取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号.
     takeUntil:(RACSignal *):获取信号直到某个信号执行完成
     skip:(NSUInteger):跳过几个信号,不接受。
     switchToLatest:用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。
     
     doNext: 执行Next之前，会先执行这个Block
     deliverOn: 内容传递切换到制定线程中，副作用在原来线程中,把在创建信号时block中的代码称之为副作用。
     subscribeOn: 内容传递和副作用都会切换到制定线程中。
     timeout：超时，可以让一个信号在一定的时间后，自动报错。
     interval 定时：每隔一段时间发出信号
     delay 延迟发送next。
     retry重试 ：只要失败，就会重新执行创建信号中的block,直到成功.
     replay重放：当一个信号被多次订阅,反复播放内容
     throttle节流:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。
     */
    
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];

    // 获取信号中信号最近发出信号，订阅最近发出的信号。
    // 注意switchToLatest：只能用于信号中的信号
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {
       NSLog(@"%@",x);
    }];
    [signalOfSignals sendNext:signal];
    [signal sendNext:@1];
    
    
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      [subscriber sendNext:@1];
      [subscriber sendCompleted];
      return nil;
    }] doNext:^(id x) {
    // 执行[subscriber sendNext:@1];之前会调用这个Block
      NSLog(@"doNext");;
    }] doCompleted:^{
       // 执行[subscriber sendCompleted];之前会调用这个Block
      NSLog(@"doCompleted");;
    }] subscribeNext:^(id x) {
      NSLog(@"%@",x);
    }];
    
    RACSignal *delaySignal = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
     [subscriber sendNext:@1];
        return nil;
    }] delay:2] subscribeNext:^(id x) {
     NSLog(@"%@",x);
    }];
}


@end

