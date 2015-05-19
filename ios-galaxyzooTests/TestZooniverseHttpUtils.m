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

- (void)testGenerateContentForNameValuePairs {
    //An array of ZooniverseNameValuePair:
    NSMutableArray *nameValuePairs = [[NSMutableArray alloc] init];

    [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                            name:@"classification[subject_ids][]"
                                           value:@"504f217bc499611ea60410ed"];
    [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                            name:@"classification[annotations][0][sloan-0]"
                                           value:@"a-1"];
    [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                            name:@"classification[annotations][1][sloan-1]"
                                           value:@"a-1"];
    [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                            name:@"classification[annotations][2][sloan-2]"
                                           value:@"a-1"];
    [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                            name:@"classification[annotations][3][sloan-3]"
                                           value:@"a-0"];

    NSString *content = [ZooniverseHttpUtils generateContentForNameValuePairs:nameValuePairs];
    XCTAssert([content isEqualToString:@"classification%5Bsubject_ids%5D%5B%5D=504f217bc499611ea60410ed&classification%5Bannotations%5D%5B0%5D%5Bsloan-0%5D=a-1&classification%5Bannotations%5D%5B1%5D%5Bsloan-1%5D=a-1&classification%5Bannotations%5D%5B2%5D%5Bsloan-2%5D=a-1&classification%5Bannotations%5D%5B3%5D%5Bsloan-3%5D=a-0"],
              @"Pass");

}

@end
