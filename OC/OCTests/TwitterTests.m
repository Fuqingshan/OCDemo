//
//  TwitterTests.m
//  OCMockTestTests
//
//  Created by yier on 2020/2/26.
//  Copyright © 2020 yier. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "TwitterPerson.h"
#import "TwitterViewController.h"
#import "TwitterConnection.h"
#import "TwitterView.h"
#import "Twitter.h"

@interface TwitterTests : XCTestCase

@end

@implementation TwitterTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

//最简单的一个使用OCMock的例子
- (void)testPersonNameEqual{
    TwitterPerson *person = [TwitterPerson new];
    
    //创建一个mock对象
    id mockClass = OCMClassMock([TwitterPerson class]);
    
    //可以给这个mock对象的方法设置预设的参数和返回值
    OCMStub([mockClass getPersonName]).andReturn(@"其他打算");
    
    //用这个预设的值和实际的值进行比较是否相等
    XCTAssertEqualObjects([mockClass getPersonName], [person getPersonName],@"值相等");
    
}

//example1
- (void)testDisplaysTwitterRetrievedFromConnection{
    TwitterViewController *controller = [[TwitterViewController alloc] init];
    
    //模拟出来一个网络请求
    id mockConnection = OCMClassMock([TwitterConnection class]);
    controller.connection = mockConnection;
    
    //模拟fetchTwitter方法返回预设值
    Twitter *t1 = [Twitter new];
    t1.userName = @"123";
    Twitter *t2 = [Twitter new];
    t2.userName = @"456";
    
    NSArray *array = @[t1,t2];
    OCMStub([mockConnection fetchTwitters]).andReturn(array);
    
    //模拟一个View
    id mockView = OCMClassMock([TwitterView class]);
    
    controller.twitterView = mockView;
    
    //这里执行updateTwitterViewa把t1 t2加入twitterView
    [controller updateTwitterView];
    
    
    //验证使用对应参数的方法是否被调用
    OCMVerify([mockView addTweet:t1]);
    OCMVerify([mockView addTweet:t2]);
    OCMVerify([mockView addTweet:[OCMArg any]]); ///[OCMArg any]匹配所有的参数值，既t1和t2
    
        //失败，因为执行[controller updateTwitterView];的时候，mockView没有添加t3，所以验证不通过
    //    TwitterView *t3 = [[TwitterView alloc] init];
    //    t3.userName = @"斗战胜佛";
    //    OCMVerify([mockView addTweet:t3]);
}

//example2
- (void)testStrictMock3{
    //OCMClassMock一般的普通校验,没有写预期的方法也不会抛异常
    //OCMStrictClassMock为严格校验，没有预期的方法会报错
//    id classMock = OCMClassMock([TwitterView class]);
    id classMock = OCMStrictClassMock([TwitterView class]);
    //这个classMock需要执行addTweet方法且参数不为nil。  不然的话会抛出异常
    OCMExpect([classMock addTweet:[OCMArg isNotNil]]);
    OCMStub([classMock addTweet:[OCMArg isNotNil]]);
    
    /*如果不执行以下代码的话会抛异常*/
    Twitter *t = [Twitter new];
    t.userName = @"123";
    [classMock addTweet:t];
    
    OCMVerifyAll(classMock);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
