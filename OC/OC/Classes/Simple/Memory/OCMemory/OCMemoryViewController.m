//
//  OCMemoryViewController.m
//  OC
//
//  Created by yier on 2019/2/21.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCMemoryViewController.h"

@interface OCMemoryViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation OCMemoryViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"内存管理");
}

- (void)initData{
    self.textView.text = @"~在运行时, Objective-C程序创建的对象(通过 NSObject类的alloc方法)会以动态方式存储在预先分配的内存区域中,这片内存区域称为堆内存。以动态方式创建对象意味着需要管理内存,因为在堆内存中创建的对象会一直使用该区域中的内存。不进行内存管理或者采用错误的内存管理方式,通常会导致内存泄漏和悬挂指针问题。\n~Objective-C的内存管理是使用引用计数实现的,该技术通过对象的唯一引用判断对象是否正在被使用。如果某个对象的引用计数变为0,那么就会被视为不再有用,运行时系统会释放它占用的内存。\n~苹果公司的 Objective-C开发环境提供了两种内存管理机制:手动管理(MRR)和自动引用计数(ARC)。\n~在使用MR内存管理方式时,需要编写确切的代码,管理对象的生命周期、获取对象(你创建的或需要使用的)所有权和释放对象(不再需要的)所有权。\n~ARC使用的引用计数模型与MR使用的引用计数模型相同,但是它通过编译器自动管理对象的生命周期。在编译程序时,编译器会分析源代~ARC中增加了新的对象生命周期限定符,使用这些限定符可以确切地声明对象变量和属性的生命周期,还可以实现弱引用功能,避免出现循环引用。\n~ARC能够以工程为单位应用,也能够以文件为单位应用,因此ARC代码可以与非ARC代码共存。苹果公司还提供了一种转换工具,使用它可以将已存在的非ARC代码转换为ARC代码。苹果公司推荐在所有新的 Objective-C工程中使用ARC管理内存。\n";
    [self.textView scrollRangeToVisible:NSMakeRange(0, 1)];
}

#pragma mark - setupUI

#pragma mark - initData
@end
