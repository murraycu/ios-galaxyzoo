//
//  TestDecisionTree.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 08/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DecisionTree.h"

@interface TestDecisionTree : XCTestCase

@end

@implementation TestDecisionTree

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (DecisionTree *)createCorrectDecisionTree {
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"test_decision_tree.xml"
                                         withExtension:nil];
    XCTAssert(url != nil, @"Pass");

    DecisionTree *result = [[DecisionTree alloc] init:url
                            withDiscussQuestion:nil];
    XCTAssert(result != nil, @"Pass");

    return result;
}

- (void)testSize {
    DecisionTree *decisionTree = [self createCorrectDecisionTree];
    XCTAssert(decisionTree != nil, @"Pass");

    NSArray *questions = [decisionTree getAllQuestions];
    XCTAssert(questions.count == 12, @"Pass");

    XCTAssert(YES, @"Pass");
}

- (void)testQuestionsWithoutTranslations {
    DecisionTree *decisionTree = [self createCorrectDecisionTree];
    XCTAssert(decisionTree != nil, @"Pass");

    NSString *QUESTION_ID = @"sloan-3";
    DecisionTreeQuestion *question = [decisionTree getQuestion:QUESTION_ID];
    XCTAssertEqualObjects(QUESTION_ID, question.questionId);
    XCTAssertEqualObjects(@"Spiral", question.title);
    XCTAssertEqualObjects(@"Is there any sign of a spiral arm pattern?", question.text);

    DecisionTreeQuestion *nextQuestion = [decisionTree getNextQuestion:QUESTION_ID
                                                                        forAnswer:@"a-1"];
    XCTAssertEqualObjects(@"sloan-4", nextQuestion.questionId);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
