//
//  DecisionTree.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecisionTreeQuestion.h"
#import "DecisionTreeDiscussQuestion.h"

//TODO: Separate the parser?
@interface DecisionTree : NSObject

- (DecisionTree *)init:(NSURL *)url
   withDiscussQuestion:(DecisionTreeDiscussQuestion *)discussQuestion;

@property (nonatomic, copy, readonly) NSString *firstQuestionId;
@property (nonatomic, copy, readonly) DecisionTreeDiscussQuestion *discussQuestion;



//TODO: Create a read-only property instead?
- (NSArray *)getAllQuestions;

- (DecisionTreeQuestion *) getQuestion:(NSString *)questionId;

- (DecisionTreeQuestion *) getNextQuestion:(NSString *)questionId forAnswer:(NSString *)answerId;

- (void)addQuestion:(DecisionTreeQuestion *)question;
@end
