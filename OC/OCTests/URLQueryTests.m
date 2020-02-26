//
//  URLQueryTests.m
//  OCTests
//
//  Created by yier on 2020/2/24.
//  Copyright © 2020 yier. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+URLQuery.h"

@interface URLQueryTests : XCTestCase

@end

@implementation URLQueryTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [self transformQueryParams:@"https://www.baidu.com?title=是是"];
}

- (void)transformQueryParams:(NSString *)url{
    NSDictionary *dic = url.params;
    NSString *title = dic[@"title"];
    XCTAssert([title isEqualToString:@"是是"],@"title不一致");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        NSMutableArray *arr = [[NSMutableArray alloc] init];
           for (NSInteger i = 0; i < 10000; i++) {
               NSObject *o = [NSObject new];
               [arr addObject:o];
           }
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
