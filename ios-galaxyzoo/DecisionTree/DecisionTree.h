//
//  DecisionTree.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecisionTreeQuestion.h"

//TODO: Separate the parser?
@interface DecisionTree : NSObject

- (DecisionTree *)init:(NSURL *)url;

@property (nonatomic, copy, readonly) NSString *firstQuestionId;

- (DecisionTreeQuestion *) getNextQuestion:(NSString *)questionId forAnswer:(NSString *)answerId;

- (void)addQuestion:(DecisionTreeQuestion *)question;
@end
