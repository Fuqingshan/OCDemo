//
//  AdvantageViewController.m
//  OC
//
//  Created by yier on 2019/2/18.
//  Copyright © 2019 yier. All rights reserved.
//

#import "AdvantageViewController.h"

@interface AdvantageViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation AdvantageViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"OC优势");
}

- (void)initData{
    self.textView.text = @"~面向对象的编程功能: Objective-C编程语言为面向对象的程序设计(OOP)提供了全面的支持,其中包括对象消息、封装、继承、多态和开放式递归等功能。口对象消息传递:该功能使对象能够通过彼此传递消息协同工作。实际上, Objective-C代码(如类、对象方法或函数)会向接收对象(接收器)发送消息,然后接收器会使用该消息调用相应的方法,并在有需要时返回结果。如果接收器没有相应的方法,也可以使用其他方式处理该消息,如将其发送给另一个对象、向其他对象广播该消息、检查该消息并应用自定义逻辑等。\n~动态的运行时环境:与许多面向对象的编程语言相比, Objective-C拥有非常多的动态特性。它将许多处理类型、消息和方法决议( method resolution)的工作转移到运行程序的时候进行,而不是在编译或链接时处理。使用这些功能能够以实时方式,同时促进程序的开发和更新,而无需重新编译和部署软件,而且随着时间的推移,这样做对现有软件的影响最小甚至没有影响。\n~内存管理:oυ ojective-C提供了内存管理功能——自动引用计数(ARC),使用该功能既可以简化应用开发过程,又可以提高应用的性能。ARC是一种编译时技术,它整合了传统内存自动化管理机制(如垃圾回收器)的许多优点。然而,与传统技术相比,ARC可以提供更好的性能(内存管理代码会在编译时被插亼到程序代码中),因而不会在执行程序时引起由内存管理原因导致的暂停。\n~内部检查和获取信息:通过 Objective-C语言提供的功能,程序能够在运行时检查对象、获取信息(对象的类型、属性和该对象支持的方法),以及修改对象的结构和行为。这样就可以在执行程序时修改程序。\n~对C语言的支持: Objective-C实际上是C语言面向对象编程的扩展。所以,它是C语言的超集。这意味着 Objective-C程序中可以使用不经修改的原始C语言代码,而且 Objective-C程序也可以直接访问C语言标准函数库。\n~苹果公司的技术:苹果公司为 Objective-C应用开发提供了丰富的软件库和工具。这些开发工具拥有含基础设施的框架和库,让你可以集中精力开发应用。 Xcode是苹果公司提供的集成开发环境,提供了使用 Objective-C开发应用所需的所有工具。";
    [self.textView scrollRangeToVisible:NSMakeRange(0, 1)];
}

@end
