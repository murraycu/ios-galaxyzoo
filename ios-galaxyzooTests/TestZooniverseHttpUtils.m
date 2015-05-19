//
//  TestZooniverseHttpUtils.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 19/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ZooniverseHttpUtils.h"

@interface TestZooniverseHttpUtils : XCTestCase

@end

@implementation TestZooniverseHttpUtils

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUrlEncodeValue {
    NSString *encoded = [ZooniverseHttpUtils urlEncodeValue:@"Some input text"];
    XCTAssert([encoded isEqualToString:@"Some%20input%20text"], @"Pass");

    encoded = [ZooniverseHttpUtils urlEncodeValue:@"Some [input] text"];
    XCTAssert([encoded isEqualToString:@"Some%20%5Binput%5D%20text"], @"Pass");

    encoded = [ZooniverseHttpUtils urlEncodeValue:@"Some & % text"];
    XCTAssert([encoded isEqualToString:@"Some%20&%20%25%20text"], @"Pass");

    encoded = [ZooniverseHttpUtils urlEncodeValue:@"Some = text"];
    XCTAssert([encoded isEqualToString:@"Some%20=%20text"], @"Pass");

    encoded = [ZooniverseHttpUtils urlEncodeValue:@"Some\ntext"];
    XCTAssert([encoded isEqualToString:@"Some%0Atext"], @"Pass");
}

- (void)testGenerateAuthorizationHeader {
    NSString *header = [ZooniverseHttpUtils generateAuthorizationHeader:@"somename"
                                                             authApiKey:@"somekey123"];

    XCTAssert([header isEqualToString:@"Basic c29tZW5hbWU6c29tZWtleTEyMw=="], @"Pass");
}

@end
