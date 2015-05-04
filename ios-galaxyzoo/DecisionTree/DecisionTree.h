//
//  DecisionTree.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecisionTreeQuestion.h"

@interface DecisionTree : NSObject

- (DecisionTree *)init:(NSString *)filename;

- (DecisionTreeQuestion *) getFirstQuestion;
- (DecisionTreeQuestion *) getNextQuestion:(NSString *)questionId forAnswer:(NSString *)answerId;
@end
