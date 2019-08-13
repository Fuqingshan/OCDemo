//
//  ConstructorViewController.m
//  OC
//
//  Created by yier on 2019/2/19.
//  Copyright © 2019 yier. All rights reserved.
//

#import "ConstructorViewController.h"
#import "Eunuch.h"

@interface ConstructorViewController ()

@end

@implementation ConstructorViewController

/*
 constructor 和 +load 都是在 main 函数执行前调用，但 +load 比 constructor 更加早一丢丢，因为 dyld（动态链接器，程序的最初起点）在加载 image（可以理解成 Mach-O 文件）时会先通知 objc runtime 去加载其中所有的类，每加载一个类时，它的 +load 随之调用，全部加载完成后，dyld 才会调用这个 image 中所有的 constructor 方法。
 
 所以 constructor 是一个干坏事的绝佳时机：
 
 所有 Class 都已经加载完成
 main 函数还未执行
 无需像 +load 还得挂载在一个 Class 中
 */

//101指的优先级,constructor数字越小优先级越高,destructor数字越大优先级越高,0~100默认为系统所用
__attribute__ ((constructor(101))) void before_main1(){
    printf("OC --- start101\n");
}

__attribute__ ((constructor(102))) void before_main2(){
    printf("OC --- start102\n");
}

__attribute__ ((destructor(101))) void after_main1(){
    printf("OC --- end101\n");
}

__attribute__ ((destructor(102))) void after_main2(){
    printf("OC --- end102\n");
}

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = @"Constructor";
    UIButton *touch = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 30)];
    [touch setTitle:@"点击" forState:UIControlStateNormal];
    [touch setBackgroundColor:LKHexColor(0x4C000000)];
    [touch setTitleColor:LKHexColor(0xFFFFFF) forState:UIControlStateNormal];
    [touch addTarget:self action:@selector(touchEunuch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:touch];
}

- (void)initData{
    //onExit用cleanup实现__attribute__((cleanup(rac_executeCleanupBlock), unused))
    @onExit{
        NSLog(@"最后执行@onExit");
    };
    NSLog(@"比@onExit先执行");
    [self testUnuse];
    [self testOverloadable];
    
    NSLog(@"%@", NSStringFromClass([Sark class])); // "40ea43d7629d01e4b8d6289a132482d0dd5df4fa"
}

//warn_unused_result 会检查是否使用返回值，没使用会报⚠️,用于返回值比较关键的地方
- (BOOL)testUnuse __attribute__((warn_unused_result)){
    return YES;
}

- (void)touchEunuch{
    Son *s = [[Son alloc] init];
    [s walk];
    
    printValidAge(110);//正确
//    printValidAge(130);//编译异常
}

//void printValidAge(int age);//enable_if，静态检测，只能加在c函数后面
static void printValidAge(int age) __attribute__((enable_if(age > 0 && age < 120, "你丫火星人？"))) {
    printf("%d", age);
}

#pragma mark - c语言实现的类重载_attribute__((overloadable))

- (void)testOverloadable{
    logAnything(@[@"1", @"2"]);
    logAnything(233);
    logAnything(CGRectMake(1, 2, 3, 4));
}

__attribute__((overloadable)) void logAnything(id obj) {
    NSLog(@"%@", obj);
}
__attribute__((overloadable)) void logAnything(int number) {
    NSLog(@"%@", @(number));
}
__attribute__((overloadable)) void logAnything(CGRect rect) {
    NSLog(@"%@", NSStringFromCGRect(rect));
}

@end
