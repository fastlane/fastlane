//
//  appTests.m
//  appTests
//
//  Created by Felix Krause on 01/10/15.
//  Copyright © 2015 Felix Krause. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface appTests : XCTestCase

@end

@implementation appTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssert(1 == 2 - 1);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        NSLog(@"performance");
    }];
}

@end
