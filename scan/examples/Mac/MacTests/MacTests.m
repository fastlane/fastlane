//
//  MacTests.m
//  MacTests
//
//  Created by Felix Krause on 10/14/15.
//  Copyright © 2015 Felix Krause. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface MacTests : XCTestCase

@end

@implementation MacTests

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
    XCTAssert(0 == 0);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
