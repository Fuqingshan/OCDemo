//
//  PersonTestCase.m
//  UnitTests
//
//  Created by yier on 2020/2/23.
//  Copyright © 2020 yier. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UnitTestPerson.h"

@interface PersonTestCase : XCTestCase

@end

@implementation PersonTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // 1.测试 name和age 是否一致
    [self checkPersonWithDict:@{@"name":@"zhou", @"age":@30}];
    
    /** 2.测试出 age 不符合实际，那么需要在字典转模型方法中对age加以判断：
     if (obj.age <= 0 || obj.age >= 130) {
     obj.age = 0;
     }
     */
    [self checkPersonWithDict:@{@"name":@"zhang",@"age":@200}];
    
    // 3.测试出 name 为nil的情况，因此在XCTAssert里添加条件：“person.name == nil“
    [self checkPersonWithDict:@{}];
    
    // 4.测试出 Person类中没有 title 这个key，在字典转模型方法中实现：- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}
    [self checkPersonWithDict:@{@"name":@"zhou", @"age":@30, @"title":@"boss"}];
    
    // 5.总体再验证一遍，结果Build Succeeded，测试全部通过
    [self checkPersonWithDict:@{@"name":@"zhou", @"age":@-1, @"title":@"boss"}];
    
    // 到目前为止 Person 的 工厂方法测试完成！✅
}

- (void)checkPersonWithDict:(NSDictionary *)dict{
    UnitTestPerson *person = [UnitTestPerson personWithDict:dict];
    NSLog(@"%@",person);
    
    //获取信息
    NSString *name = dict[@"name"];
    NSInteger age = [dict[@"age"] integerValue];
    
    XCTAssert([name isEqualToString:person.name] || person.name == nil, @"姓名不一致");
    
    if (person.age > 0 && person.age < 130) {
        XCTAssertTrue(person.age == age, @"年龄不一致");
    }else{
        XCTAssert(person.age == 0, @"年龄超限");
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 10000; i++) {
            NSObject *o = [NSObject new];
            [arr addObject:o];
        }
        // Put the code you want to measure the time of here.
    }];
}

- (void)testAsync{
    XCTestExpectation *expect = [self expectationWithDescription:@"oh timeout!"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        XCTAssert(YES,"some error info");
        
        [expect fulfill];//告知异步测试结束;
    });
    
//    NSURL *url = [NSURL URLWithString:@""];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    NSURLSessionDataTask *task =  [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        //notify
//
//       }];

    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        //等待10秒，若该测试未结束（未收到 fulfill方法）则测试结果为失败
             //Do something when time out
        NSLog(@"wait error: %@",error);
    }];
}

@end
